Rails.application.routes.draw do
  root 'welcome#index'

  post '/summoner/name', to: 'summoners#find_by_name'
  post '/summoner/id', to: 'summoners#find_by_id'
  post '/summoner/get_league_entry', to: 'summoners#get_league_entry'
  post '/summoner/renew_league_entry', to: 'summoners#renew_league_entry'
  post '/summoner/stats_summary', to: 'summoners#stats_summary'
  post '/summoner/stats_ranked', to: 'summoners#stats_ranked'
end
