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
      case e.io.status[0]
      when "429"
        render json: {success: false, code: "tooMany"}, status: 429
      when "404"
        render json: {success: false, code: "noSummoner"}, status: 400
      else
        render json: {success: false, code: "serviceError"}, status: 500
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
      case e.io.status[0]
      when "429"
        render json: {success: false, code: "tooMany"}, status: 429
      when "404"
        render json: {success: false, code: "noSummoner"}, status: 400
      else
        render json: {success: false, code: "serviceError"}, status: 500
      end
    end
  end
  
end
