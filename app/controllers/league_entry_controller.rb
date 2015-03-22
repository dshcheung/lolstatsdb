class LeagueEntryController < ApplicationController
  include ApplicationHelper

  def get_league_entry
    summoner = Summoner.find_by(summonerId: params['id'].to_i, region: params['region'].to_s)
    if summoner[:league].nil?
      renew_league_entry
    else
      render json: {league_entry: summoner[:league], border_icon: summoner[:border_icon]}, status: 200
    end
  end

  def renew_league_entry
    summoner = Summoner.find_by(summonerId: params['id'], region: params['region'])
    info = update_league_entry(params['id'], params['region'], summoner)
    if info[:success]
      render json: info, status: 200
    else
      render json: info, status: 400
    end
  end

  def update_league_entry(id, region, summoner)
    require 'open-uri'
    require 'json'

    league = {
      solo5: nil,
      team5: nil,
      team3: nil
    }

    @tries = 0
    begin
      url = "https://#{region}.api.pvp.net/api/lol/#{region.downcase}/v2.5/league/by-summoner/#{id}/entry?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if not response.empty?
        response = response["#{id}"]
        for i in 0..response.length - 1
          league_name = response[i]['queue']
          tier = response[i]['tier'].capitalize
          division = response[i]['entries'][0]['division']
          if league_name[/(SOLO)/]
            league[:solo5] = response[i]
            league[:solo5]["badge_icon"] = ActionController::Base.helpers.asset_path("badge" +  tier + division + ".png")
            border_icon = ActionController::Base.helpers.asset_path("border" + tier + ".png")
          elsif league_name[/(TEAM)/]
            if league_name[/(5x5)/]
              league[:team5] = response[i]
              league[:team5]["badge_icon"] = ActionController::Base.helpers.asset_path("badge" +  tier + division + ".png")
            elsif league_name[/(3x3)/]
              league[:team3] = response[i]
              league[:team3]["badge_icon"] = ActionController::Base.helpers.asset_path("badge" +  tier + division + ".png")
            end
          end 
        end
        summoner.update(league: league, border_icon: border_icon)
      end
      return {success: true, league_entry: league, border_icon: border_icon}
    rescue OpenURI::HTTPError => e
      case e.io.status
      when 429
        return {success: false, code: "tooMany", league_entry: league, border_icon: nil}
      else
        summoner.update(league: league, border_icon: nil)
        return {success: false, code: "notFound", league_entry: league, border_icon: nil}
      end
    end
  end
end
