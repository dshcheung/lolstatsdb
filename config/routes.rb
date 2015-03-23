Rails.application.routes.draw do
  root 'welcome#index'

  post '/summoner/name', to: 'summoners#find_by_name'
  post '/summoner/id', to: 'summoners#find_by_id'

  post '/summoner/get_league_entry', to: 'league_entry#get_league_entry'
  post '/summoner/renew_league_entry', to: 'league_entry#renew_league_entry'

  post '/summoner/get_league_all', to: 'league_all#get_league_all'
  post '/summoner/renew_league_all', to: 'league_all#renew_league_all'

  post '/summoner/get_league_page', to: 'league_all#get_league_page'
  post '/summoner/get_icon_list', to: 'league_all#get_icon_list'

  post '/summoner/get_stats_summary', to: 'stats_summary#get_stats_summary'
  post '/summoner/renew_stats_summary', to: 'stats_summary#renew_stats_summary'
  
  post '/summoner/get_stats_ranked', to: 'stats_ranked#get_stats_ranked'
  post '/summoner/renew_stats_ranked', to: 'stats_ranked#renew_stats_ranked'

  post '/matches/get_match_histories', to: 'matches#get_match_histories'
  post '/matches/renew_match_histories', to: 'matches#renew_match_histories'

  post '/matches/get_match_details', to: 'matches#get_match_details'

  post '/matches/get_position_frequency', to: 'matches#get_position_frequency'
end
