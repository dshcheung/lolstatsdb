class SummonersController < ApplicationController
  def find
    require 'open-uri'
    require 'json'
    Dotenv::Railtie.load

    @tries = 0
    begin
      url = "https://#{params['region']}.api.pvp.net/api/lol/#{params['region']}/v1.4/summoner/by-name/#{params['summoner']}?api_key=#{ENV['API_KEY']}"
      response = JSON.parse(open(url).read)

      render json: {success: true}
    rescue OpenURI::HTTPError => e
      case rescue_me(e)
      when 1
        retry
      when 2
        render json: {success: false}
      end
    end
  end
end
