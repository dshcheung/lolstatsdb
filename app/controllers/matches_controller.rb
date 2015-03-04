class MatchesController < ApplicationController
  def get_match_histories
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(match_creation: :desc).limit(10)
    if matches.empty?
      update_match_histories(params['id'], params['region'])
    end
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(match_creation: :desc).limit(10)
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
          if match['participants'][0]['stats']['winner']
            winner = "true"
          else
            winner = "false"
          end
          champ = Champion.find_by(championId: match['participants'][0]['championId'], region: region)
          MatchHistory.create(summonerId: id,
                              matchId: match['matchId'],
                              match_creation: match['matchCreation'],
                              region: region,
                              queue: match['queueType'],
                              winner: winner,
                              championId: match['participants'][0]['championId'],
                              champion_name: champ.name,
                              champion_key: champ.name_key,
                              role: match['participants'][0]['timeline']['role'],
                              lane: match['participants'][0]['timeline']['lane'])
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

  def get_match_details
    match = MatchDetail.find_by(matchId: params['matchId'], region: params['region'])
    if match.nil?
      update_match_details(params['matchId'], params['region'])
    end
    match = MatchDetail.find_by(matchId: params['matchId'], region: params['region'])
    render json: {details: match}
  end

  def update_match_details(matchId, region)
    require 'open-uri'
    require 'json'

    @tries = 0
    begin
      url = "https://#{region.downcase}.api.pvp.net/api/lol/#{region.downcase}/v2.2/match/#{matchId}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)

      names = []
      name_keys = []
      if not response.empty?
        participants = []
        response['participants'].each_with_index do |participant, index|
          if participant['stats']['winner']
            winner = "true"
          else
            winner = "false"
          end
          champ = Champion.find_by(championId: participant['championId'], region: region)
          names.push(champ.name)
          name_keys.push(champ.name_key)
          MatchHistory.create(summonerId: response['participantIdentities'][index]['player']['summonerId'],
                              matchId: response['matchId'],
                              match_creation: response['matchCreation'],
                              region: region,
                              queue: response['queueType'],
                              winner: winner,
                              championId: participant['championId'],
                              champion_name: champ.name,
                              champion_key: champ.name_key,
                              role: participant['timeline']['role'],
                              lane: participant['timeline']['lane'])

          participants.push(participant)
          participants[index][:champion_name] = champ.name
          participants[index][:champion_name_key] = champ.name_key
        end
        MatchDetail.create(matchId: response['matchId'],
                           region: region,
                           participants: participants,
                           participant_identities: response['participantIdentities'])
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
