Rails.application.routes.draw do
  root 'welcome#index'

  post '/summoner/name', to: 'summoners#find_by_name'
  post '/summoner/id', to: 'summoners#find_by_id'
  post '/summoner/league_entry', to: 'summoners#league_entry'
end
