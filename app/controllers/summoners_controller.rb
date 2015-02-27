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
      puts url
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
end


# {"20018618":{"id":20018618,"name":"'Harunoame'","profileIconId":744,"summonerLevel":30,"revisionDate":1425002066000}}