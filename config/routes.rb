Rails.application.routes.draw do
  root 'welcome#index'

  post '/summoner', to: 'summoners#find'
end
