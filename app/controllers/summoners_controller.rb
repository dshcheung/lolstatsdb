class SummonersController < ApplicationController
  def find
    require 'open-uri'
    require 'json'
    Dotenv::Railtie.load

    @tries = 0
    begin
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.4/summoner/by-name/#{params['summoner'].downcase}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)

      if response.empty?
        render json: {success: true, summoner: nil}, status: 200
      else
        render json: {success: true, summoner: response["#{params['summoner'].downcase}"]}, status: 200
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
