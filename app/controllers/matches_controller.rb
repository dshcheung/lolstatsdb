class MatchesController < ApplicationController
  def get_match_histories
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(match_creation: :desc).limit(10)
    if matches.empty?
      renew_match_histories
    else
      matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(match_creation: :desc).limit(10)
      render json: {match_history: matches}, status: 200
    end
  end

  def renew_match_histories
    info = update_match_histories(params['id'], params['region'])
    matches = MatchHistory.where(summonerId: params['id'], region: params['region']).order(match_creation: :desc).limit(10)
    if info[:success]
      render json: {match_history: matches}, status: 200
    else
      render json: {match_history: matches, code: info[:code]}, status: 400
    end
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
      return {success: true}
    rescue OpenURI::HTTPError => e
      case e.io.status[0]
      when "429"
        return {success: false, code: "tooMany"}
      when "404"
        return {success: false, code: "serviceError"}
      else
        return {success: false, code: "serviceError"}
      end
    end
  end

  def get_match_details
    match = MatchDetail.find_by(matchId: params['matchId'], region: params['region'])
    if match.nil?
      info = update_match_details(params['matchId'], params['region'])
      if info[:success]
        match = MatchDetail.find_by(matchId: params['matchId'], region: params['region'])
        render json: {details: match}, status: 200
      else
        match = MatchDetail.find_by(matchId: params['matchId'], region: params['region'])
        render json: {details: match, code: info[:code]}, status: 400
      end
    else
      match = MatchDetail.find_by(matchId: params['matchId'], region: params['region'])
      render json: {details: match}, status: 200
    end
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
      return {success: true}
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when "429"
        return {success: true, code: "tooMany"}
      when "404"
        return {success: true, code: "serviceError"}
      else
        return {success: true, code: "serviceError"}
      end
    end
  end

  def get_position_frequency
    matches = MatchHistory.where(summonerId: params["id"], region: params["region"]).order(match_creation: :desc).limit(10)
    frequency = { data: [{x: "Top", y: [0], tooltip: "Top"}, {x: "Middle", y: [0], tooltip: "Middle"}, {x: "Jungle", y: [0], tooltip: "Jungle"}, {x: "Support", y: [0], tooltip: "Support"}, {x: "ADC", y: [0], tooltip: "ADC"}]}

    adc = {"Ashe"=> true, "Caitlyn"=> true, "Corki"=> true, "Draven"=> true, "Ezreal"=> true, "Graves"=> true, "Jinx"=> true, "Kalista"=> true, "Kog'Maw"=> true, "Lucian"=> true, "Miss Fortune"=> true, "Quinn"=> true, "Sivir"=> true, "Teemo"=> true, "Tristana"=> true, "Twitch"=> true, "Urgot"=> true, "Varus"=> true, "Vayne"=> true}

    matches.each do |match|
      case match.role
      when "TOP"
        frequency[:data][0][:y][0] += 1
      when "MIDDLE"
        frequency[:data][1][:y][0] += 1
      when "NONE"
        frequency[:data][2][:y][0] += 1
      when "DUO_SUPPORT"
        frequency[:data][3][:y][0] += 1
      when "DUO_CARRY"
        frequency[:data][4][:y][0] += 1
      when "DUO"
        if adc[match.champion_name].nil?
          frequency[:data][3][:y][0] += 1
        else
          frequency[:data][4][:y][0] += 1
        end
      end
    end
    render json: {frequency: frequency}
  end
end
