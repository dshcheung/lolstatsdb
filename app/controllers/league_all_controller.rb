class LeagueAllController < ApplicationController
  include ApplicationHelper

   def get_league_all
    summoner_existance = League.find_by(region: params['region'], queue: params['queue'], name: params['leagueName'], tier: params['tier'], division: params['division'], summonerId: params['id'])
    if summoner_existance.nil?
      renew_league_all
    else
      render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName']), status: 200
    end
  end

  def renew_league_all
    info = update_league_all(params['region'], params['id'])
    page = league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName'])
    page[:code] = info[:code]
    if info[:success]
      render json: page, status: 200
    else
      render json: page, status: 400
    end
  end

  def get_league_page
    render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName']), status: 200
  end

  def destroy_old_leagues(id, queue)
    entries = League.where(summonerId: id, queue: queue)
    if not entries.empty?
      entries.each do |entry|
        League.where(region: entry.region, queue: entry.queue, name: entry.name, tier: entry.tier).destroy_all
      end
    end
  end

  def update_league_all(region, id)
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      url = "https://#{region}.api.pvp.net/api/lol/#{region.downcase}/v2.5/league/by-summoner/#{id}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      
      if not response.empty?
        response = response["#{id}"]
        response.each do |league|
          league_name = league["name"]
          league_queue = league["queue"]
          league_tier = league["tier"]
          destroy_old_leagues(id, league_queue)
          league["entries"].each do |entry|
            League.create(region: region,
                          queue: league_queue,
                          name: league_name,
                          tier: league_tier,
                          division: entry["division"],
                          summonerId: entry["playerOrTeamId"],
                          league_points: entry["leaguePoints"],
                          entry: entry)
          end
        end
      end
      return {success: true, code: "success"}
    rescue OpenURI::HTTPError => e
      case e.io.status[0]
      when "429"
        return {success: false, code: "tooMany"}
      when "404"
        return {success: false, code: "notFound"}
      else
        return {success: false, code: "serviceError"}
      end
    end
  end

  def league_page(region, queue, tier, division, leagueName)
    badge_icon = ActionController::Base.helpers.asset_path("badge" +  tier.capitalize + division + ".png")
    league_promo = League.where(region: region, queue: queue, name: leagueName, tier: tier, division: division, league_points: 100).order(:league_points)
    league_normal = League.where(region: region, queue: queue, name: leagueName, tier: tier, division: division, league_points: 0..99).order(:league_points).reverse
    if tier == "CHALLENGER"
      league_challenger = League.where(region: region, queue: queue, name: leagueName, tier: tier, division: division).order(:league_points).reverse
    end
    return {league_promo: league_promo, league_normal: league_normal, league_challenger: league_challenger, badge_icon: badge_icon}
  end

  def get_icon_list
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      region = params['region'].downcase
      source_list = params['summonerList']
      length = source_list.length
      if length > 40
        list1 = source_list[0..39].join(',')
        url = "https://#{region}.api.pvp.net/api/lol/#{region}/v1.4/summoner/#{list1}?api_key=#{ENV['API_KEY']}"
        response1 = JSON.parse(open(url).read)

        list2 = source_list[40..length-1].join(',')
        url = "https://#{region}.api.pvp.net/api/lol/#{region}/v1.4/summoner/#{list2}?api_key=#{ENV['API_KEY']}"
        response2 = JSON.parse(open(url).read)
        render json: {success: true, summoners: response1.merge(response2)}, status: 200
      else
        list = source_list.join(',')
        region = params['region'].downcase
        url = "https://#{region}.api.pvp.net/api/lol/#{region}/v1.4/summoner/#{list}?api_key=#{ENV['API_KEY']}"
        response = JSON.parse(open(url).read)
        render json: {success: true, summoners: response}, status: 200
      end
    rescue OpenURI::HTTPError => e
      case e.io.status[0]
      when "429"
        render json: {success: true, code: "tooMany", summoners: {summoners: nil}}, status: 429
      when "404"
        render json: {success: true, code: "notFound", summoners: {summoners: nil}}, status: 400
      else 
        render json: {success: true, code: "serviceError", summoners: {summoners: nil}}, status: 400
      end
    end
  end
end
