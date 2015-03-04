task :get_champion_info => :environment do
  require 'open-uri'
  require 'json'

  regions = ['BR','EUNE','EUW','KR','LAN','LAS','NA','OCE','RU','TR']
    
  regions.each do |region|
    url = "https://global.api.pvp.net/api/lol/static-data/#{region.downcase}/v1.2/champion?champData=image&api_key=#{ENV['API_KEY']}"

    response = JSON.parse(open(url).read)

    response["data"].keys.each do |champ|
      data = response["data"][champ]
      Champion.create(championId: data["id"],
                      title: data["title"],
                      name: data["name"],
                      name_key: data["key"],
                      image: data["image"],
                      region: region)
    end
  end
end
