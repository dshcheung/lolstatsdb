class StatsSummaryController < ApplicationController
  include ApplicationHelper

  def get_stats_summary
    summoner = Summoner.find_by(summonerId: params['id'].to_i, region: params['region'].to_s)
    if summoner[:stats_summary].nil?
      renew_stats_summary
    else
      render json: {stats_summary: summoner[:stats_summary]}, status: 200
    end
  end

  def renew_stats_summary
    summoner = Summoner.find_by(summonerId: params['id'], region: params['region'])
    info = update_stats_summary(params['id'], params['region'], summoner)
    if info[:success]
      render json: info, status: 200
    else
      render json: info, status: 400
    end
  end

  def update_stats_summary(id, region, summoner)
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
      url = "https://#{region}.api.pvp.net/api/lol/#{region}/v1.3/stats/by-summoner/#{id}/summary?season=SEASON2015&api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if not response.empty?
        game = response["playerStatSummaries"]
        if game != nil
          for i in 0..game.length - 1
            game_type = game[i]["playerStatSummaryType"]
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
        end
        summoner.update(stats_summary: stats)
      end
      return {success: true, stats_summary: stats}
    rescue OpenURI::HTTPError => e
      case e.io.status[0]
      when "429"
        return {success: false, code: "tooMany", stats_summary: stats}
      when "404"
        summoner.update(stats_summary: stats)
        return {success: false, code: "serviceError", stats_summary: stats}
      else 
        return {success: false, code: "serviceError", stats_summary: stats}
      end
    end
  end
end
