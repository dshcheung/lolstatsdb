class SummonersController < ApplicationController
  include ApplicationHelper

  def find_by_id
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.4/summoner/#{params['id']}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if response.empty?
        render json: {success: true, summoner: nil}, status: 200
      else
        response["#{params['id']}"]['icon'] = ActionController::Base.helpers.asset_path("profileIcon-" + response["#{params['id']}"]['profileIconId'].to_s + ".png")
        render json: {success: true, summoner: response["#{params['id']}"]}, status: 200
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}, status: 400
      end
    end
  end

  def find_by_name
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      name_utf = params['summoner'].gsub(' ', "%20")
      name_no_space = params['summoner'].gsub(' ', "")
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.4/summoner/by-name/#{name_utf.downcase}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if response.empty?
        render json: {success: true, summoner: nil}, status: 200
      else
        render json: {success: true, summoner: response["#{name_no_space.downcase}"]}, status: 200
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}, status: 400
      end
    end
  end

  def league_entry
    require 'open-uri'
    require 'json'

    league = {
      solo5: nil,
      team5: nil,
      team3: nil
    }

    @tries = 0
    begin
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region'].downcase}/v2.5/league/by-summoner/#{params['id']}/entry?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if response.empty?
        render json: {success: true, league_entry: nil}, status: 200
      else
        for i in 0..response["#{params['id']}"].length - 1
          league_name = response["#{params['id']}"][i]['queue']
          tier = response["#{params['id']}"][i]['tier'].capitalize
          division = response["#{params['id']}"][i]['entries'][0]['division']
          if league_name[/(SOLO)/]
            league[:solo5] = response["#{params['id']}"][i]
            league[:solo5]["badge_icon"] = ActionController::Base.helpers.asset_path("badge" +  tier + division + ".png")
            border_icon = ActionController::Base.helpers.asset_path("border" + tier + ".png")
          elsif league_name[/(TEAM)/]
            if league_name[/(5x5)/]
              league[:team5] = response["#{params['id']}"][i]
              league[:team5]["badge_icon"] = ActionController::Base.helpers.asset_path("badge" +  tier + division + ".png")
            elsif league_name[/(3x3)/]
              league[:team3] = response["#{params['id']}"][i]
              league[:team3]["badge_icon"] = ActionController::Base.helpers.asset_path("badge" +  tier + division + ".png")
            end
          end 
        end
        render json: {success: true, league_entry: league, border_icon: border_icon}, status: 200
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}, status: 400
      end
    end
  end

  def stats_summary
    require 'open-uri'
    require 'json'

    stats = {
      rank_team5: {
        stats: nil,
        title: "Ranked TEAM 5x5"
      },
      rank_solo5: {
        stats: nil,
        title: "Ranked SOLO 5x5"
      },
      rank_team3: {
        stats: nil,
        title: "Ranked TEAM 3x3"
      },
      normal_team5: {
        stats: nil,
        title: "Normal 5x5"
      },
      normal_team3: {
        stats: nil,
        title: "Normal 3x3"
      }
    }

    @tries = 0
    begin
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.3/stats/by-summoner/#{params['id']}/summary?season=SEASON2015&api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if response.empty?
        render json: {success: true, stats: stats}, status: 200
      else
        game = response["playerStatSummaries"]
        for i in 0..game.length - 1
          game_type = response["playerStatSummaries"][i]["playerStatSummaryType"]
          puts "#{i}"
          if game_type == "RankedTeam5x5"
            stats[:rank_team5][:stats] = game[i]
          elsif game_type == "RankedSolo5x5"
            stats[:rank_solo5][:stats] = game[i]
          elsif game_type == "RankedTeam3x3"
            stats[:rank_team3][:stats] = game[i]
          elsif game_type == "Unranked"
            stats[:normal_team5][:stats] = game[i]
          elsif game_type == "Unranked3x3"
            stats[:normal_team3][:stats] = game[i]
          end
        end
        render json: {success: true, stats: stats}, status: 200
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}, status: 400
      end
    end
  end
end
