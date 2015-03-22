class StatsRankedController < ApplicationController
  include ApplicationHelper
  
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
