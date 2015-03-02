Rails.application.routes.draw do
  root 'welcome#index'

  post '/summoner/name', to: 'summoners#find_by_name'
  post '/summoner/id', to: 'summoners#find_by_id'

  post '/summoner/get_league_entry', to: 'summoners#get_league_entry'
  post '/summoner/renew_league_entry', to: 'summoners#renew_league_entry'

  post '/summoner/get_league_all', to: 'summoners#get_league_all'
  post '/summoner/renew_league_all', to: 'summoners#renew_league_all'

  post '/summoner/get_stats_summary', to: 'summoners#get_stats_summary'
  post '/summoner/renew_stats_summary', to: 'summoners#renew_stats_summary'
  
  post '/summoner/get_stats_ranked', to: 'summoners#get_stats_ranked'
  post '/summoner/renew_stats_ranked', to: 'summoners#renew_stats_ranked'
end
