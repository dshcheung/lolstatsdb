class MatchesController < ApplicationController
  def get_match_histories
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(:match_creation).limit(10).reverse
    if matches.empty?
      update_match_histories(params['id'], params['region'])
    end
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(:match_creation).limit(10).reverse
    render json: {match_history: matches}
  end

  def renew_match_histories
    update_match_histories(params['id'], params['region'])
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(:match_creation).limit(10).reverse
    render json: {match_history: matches}
  end

  def update_match_histories(id, region)
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      url = "https://#{region.downcase}.api.pvp.net/api/lol/#{region.downcase}/v2.2/matchhistory/#{id}?beginIndex=0&endIndex=14&api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)

      if not response.empty?
        response['matches'].each do |match|
          MatchHistory.create(summonerId: id,
                              matchId: match['matchId'],
                              match_creation: match['matchCreation'],
                              region: region,
                              queue: match['queueType'],
                              championId: match['championId'],
                              winner: match['participants'][0]['stats']['winner'],
                              role: match['participants'][0]['timeline']['role'],
                              lane: match['participants'][0]['timeline']['lane'],
                              match: match)
        end
      end
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        return e
      end
    end
  end
end
