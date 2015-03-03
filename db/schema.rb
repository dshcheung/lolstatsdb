# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150303095710) do

  create_table "champions", force: true do |t|
    t.integer  "championId"
    t.string   "title"
    t.string   "name"
    t.string   "name_key"
    t.text     "image"
    t.string   "region"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "detail_matches", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", force: true do |t|
    t.string   "region"
    t.string   "queue"
    t.string   "name"
    t.string   "tier"
    t.string   "division"
    t.integer  "summonerId"
    t.integer  "league_points"
    t.text     "entry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_histories", force: true do |t|
    t.integer  "summonerId"
    t.integer  "matchId"
    t.integer  "match_creation"
    t.string   "region"
    t.string   "queue"
    t.integer  "championId"
    t.string   "winner"
    t.string   "role"
    t.string   "lane"
    t.text     "match"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stats_rankeds", force: true do |t|
    t.integer  "championId"
    t.string   "champion_name"
    t.string   "champion_name_key"
    t.integer  "penta_kills"
    t.integer  "quadra_kills"
    t.integer  "triple_kills"
    t.integer  "double_kills"
    t.integer  "total_kills"
    t.float    "average_kills"
    t.integer  "total_assists"
    t.float    "average_assists"
    t.integer  "total_deaths"
    t.float    "average_deaths"
    t.integer  "total_minions"
    t.integer  "average_minions"
    t.integer  "total_gold"
    t.integer  "average_gold"
    t.integer  "total_games"
    t.integer  "total_wins"
    t.integer  "total_losses"
    t.float    "win_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "summoner_stats_lists", force: true do |t|
    t.integer  "stats_ranked_id"
    t.integer  "summoner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "summoners", force: true do |t|
    t.string   "region"
    t.string   "name"
    t.integer  "summonerId"
    t.integer  "profileIconId"
    t.integer  "level"
    t.text     "league"
    t.string   "border_icon"
    t.text     "stats_summary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
