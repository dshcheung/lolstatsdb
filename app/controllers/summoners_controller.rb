class SummonersController < ApplicationController
  include ApplicationHelper

  def find_by_name
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      name_utf = params['summoner'].gsub(' ', "%20")
      name_no_space = params['summoner'].gsub(' ', "")
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.4/summoner/by-name/#{name_utf.downcase}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if not response.empty?
        response = response["#{name_no_space.downcase}"]
        summoner = Summoner.find_by(summonerId: response['id'])
        if summoner.nil?
          summoner = Summoner.create(name: response['name'], profileIconId: response['profileIconId'], level: response['summonerLevel'], summonerId: response['id'], region: params['region'])
        else
          summoner.update(name: response['name'], profileIconId: response['profileIconId'], level: response['summonerLevel'], summonerId: response['id'], region: params['region'])
        end
      end
      render json: {success: true, summoner: summoner}, status: 200
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}, status: 400
      end
    end
  end

  def find_by_id
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.4/summoner/#{params['id']}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if not response.empty?
        response = response["#{params['id']}"]
        summoner = Summoner.find_by(summonerId: params['id'])
        if summoner.nil?
          summoner = Summoner.create(name: response['name'], profileIconId: response['profileIconId'], level: response['summonerLevel'], summonerId: response['id'], region: params['region'])
        else 
          summoner.update(name: response['name'], profileIconId: response['profileIconId'], level: response['summonerLevel'], summonerId: response['id'], region: params['region'])
        end
      end
      render json: {success: true, summoner: summoner}, status: 200
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}, status: 400
      end
    end
  end

  def get_league_all
    summoner_existance = League.find_by(region: params['region'], queue: params['queue'], name: params['leagueName'], tier: params['tier'], division: params['division'], summonerId: params['id'])
    if summoner_existance.nil?
      if update_league_all(params['region'], params['id'])
        render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName'])
      else
        render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName']), status: 400
      end
    else
      render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName'])
    end
  end

  def renew_league_all
    if update_league_all(params['region'], params['id'])
      render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName'])
    else
      render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName']), status: 400
    end
  end

  def get_league_page
    render json: league_page(params['region'], params['queue'], params['tier'], params['division'], params['leagueName'])
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
          League.where(region: region, queue: league_queue, name: league_name, tier: league_tier).destroy_all
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
      return true
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return false
      end
    end
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
        render json: {summoners: response1.merge(response2)}
      else
        list = source_list.join(',')
        region = params['region'].downcase
        url = "https://#{region}.api.pvp.net/api/lol/#{region}/v1.4/summoner/#{list}?api_key=#{ENV['API_KEY']}"
        response = JSON.parse(open(url).read)
        render json: {summoners: response}
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return render json: {message: "too many requests!"}, status: 400
      end
    end
  end

  def get_league_entry
    summoner = Summoner.find_by(summonerId: params['id'].to_i, region: params['region'].to_s)
    if summoner[:league].nil?
      if update_league_entry(params['id'], params['region'], summoner)
        render json: {league_entry: summoner[:league], border_icon: summoner[:border_icon]}
      else
        render json: {league_entry: summoner[:league], border_icon: summoner[:border_icon]}, status: 400
      end
    else
      render json: {league_entry: summoner[:league], border_icon: summoner[:border_icon]}
    end
  end

  def renew_league_entry
    summoner = Summoner.find_by(summonerId: params['id'], region: params['region'])
    if update_league_entry(params['id'], params['region'], summoner)
      render json: {league_entry: summoner[:league], border_icon: summoner[:border_icon]}
    else
      render json: {league_entry: summoner[:league], border_icon: summoner[:border_icon]}, status: 400
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
      return true
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        summoner.update(league: league, border_icon: nil)
        return false
      end
    end
  end

  def get_stats_summary
    summoner = Summoner.find_by(summonerId: params['id'].to_i, region: params['region'].to_s)
    if summoner[:stats_summary].nil?
      if update_stats_summary(params['id'], params['region'], summoner)
        render json: {stats_summary: summoner[:stats_summary]}
      else
        render json: {stats_summary: summoner[:stats_summary]}, status: 400
      end
    else
      render json: {stats_summary: summoner[:stats_summary]}
    end
  end

  def renew_stats_summary
    summoner = Summoner.find_by(summonerId: params['id'], region: params['region'])
    if update_stats_summary(params['id'], params['region'], summoner)
      render json: {stats_summary: summoner[:stats_summary]}
    else
      render json: {stats_summary: summoner[:stats_summary]}, status: 400
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
        summoner.update(stats_summary: stats)
      end
      return true
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        summoner.update(stats_summary: stats)
        return false
      end
    end
  end

  def get_stats_ranked
    summoner = Summoner.find_by(summonerId: params['id'], region: params['region'])
    if summoner.stats_rankeds.empty?
      if update_stats_ranked(params['id'], params['region'], summoner)
        top5 = summoner.stats_rankeds.order(total_games: :desc).limit(5)
        all_ranked = summoner.stats_rankeds
        render json: {top5: top5, all_ranked: all_ranked}
      else
        top5 = summoner.stats_rankeds.order(total_games: :desc).limit(5)
        all_ranked = summoner.stats_rankeds
        render json: {top5: top5, all_ranked: all_ranked}, status: 400;
      end
    else
      top5 = summoner.stats_rankeds.order(total_games: :desc).limit(5)
      all_ranked = summoner.stats_rankeds
      render json: {top5: top5, all_ranked: all_ranked}
    end
  end

  def renew_stats_ranked
    summoner = Summoner.find_by(summonerId: params['id'], region: params['region'])
    if update_stats_ranked(params['id'], params['region'], summoner)
      top5 = summoner.stats_rankeds.order(total_games: :desc).limit(5)
      all_ranked = summoner.stats_rankeds
      render json: {top5: top5, all_ranked: all_ranked}
    else
      top5 = summoner.stats_rankeds.order(total_games: :desc).limit(5)
      all_ranked = summoner.stats_rankeds
      render json: {top5: top5, all_ranked: all_ranked}, status: 400;
    end
  end

  def update_stats_ranked(id, region, summoner)
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      url = "https://#{region}.api.pvp.net/api/lol/#{region}/v1.3/stats/by-summoner/#{id}/ranked?season=SEASON2015&api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)
      if not response.empty?
        summoner.stats_rankeds.destroy_all
        puts "testing here -------------"
        puts response['champions'][0]['stats']['totalChampionKills']
        puts response['champions'][0]['stats']['totalSessionsPlayed']

        response['champions'].each do |champion|
          if champion['id'] == 0
            next
          end
          champ = Champion.find_by(championId: champion['id'], region: region)
          champ_name = champ.name
          champ_key = champ.name_key
          summoner.stats_rankeds.create(championId: champion['id'],
                                       champion_name: champ_name,
                                       champion_name_key: champ_key,
                                       penta_kills: champion['stats']['totalPentaKills'],
                                       quadra_kills: champion['stats']['totalQuadraKills'],
                                       triple_kills: champion['stats']['totalTripleKills'],
                                       double_kills: champion['stats']['totalDoubleKills'],
                                       total_kills: champion['stats']['totalChampionKills'],
                                       average_kills: (champion['stats']['totalChampionKills']/(champion['stats']['totalSessionsPlayed'] + 0.0)).round(1),
                                       total_assists: champion['stats']['totalAssists'],
                                       average_assists: (champion['stats']['totalAssists']/(champion['stats']['totalSessionsPlayed'] + 0.0)).round(1),
                                       total_deaths: champion['stats']['totalDeathsPerSession'],
                                       average_deaths: (champion['stats']['totalDeathsPerSession']/(champion['stats']['totalSessionsPlayed'] + 0.0)).round(1),
                                       total_minions: champion['stats']['totalMinionKills'],
                                       average_minions: (champion['stats']['totalMinionKills']/(champion['stats']['totalSessionsPlayed'] + 0.0)).round,
                                       total_gold: champion['stats']['totalGoldEarned'],
                                       average_gold: (champion['stats']['totalGoldEarned']/(champion['stats']['totalSessionsPlayed'] + 0.0)).round,
                                       total_games: champion['stats']['totalSessionsPlayed'],
                                       total_wins: champion['stats']['totalSessionsWon'],
                                       total_losses: champion['stats']['totalSessionsLost'],
                                       win_rate: (champion['stats']['totalSessionsWon']/(champion['stats']['totalSessionsPlayed'] + 0.0)).round(4))
        end
      end
      return true
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return false
      end
    end
  end
end
