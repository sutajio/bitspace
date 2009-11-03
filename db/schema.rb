# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091103161053) do

  create_table "artists", :force => true do |t|
    t.string   "mbid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "releases_count"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "token"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labels", :force => true do |t|
    t.string   "mbid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlist_items", :force => true do |t|
    t.integer  "playlist_id"
    t.integer  "user_id"
    t.integer  "track_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "releases", :force => true do |t|
    t.integer  "artist_id"
    t.integer  "label_id"
    t.string   "mbid"
    t.string   "title"
    t.integer  "year"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "artwork_file_name"
    t.string   "artwork_content_type"
    t.integer  "artwork_file_size"
    t.datetime "artwork_updated_at"
  end

  create_table "tracks", :force => true do |t|
    t.integer  "release_id"
    t.integer  "artist_id"
    t.string   "fingerprint"
    t.string   "mbid"
    t.string   "title"
    t.integer  "track_nr"
    t.integer  "length"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bitrate"
    t.integer  "samplerate"
    t.boolean  "vbr"
    t.string   "content_type"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                            :null => false
    t.string   "email",                                            :null => false
    t.string   "crypted_password",                                 :null => false
    t.string   "password_salt",                                    :null => false
    t.string   "persistence_token",                                :null => false
    t.string   "single_access_token",                              :null => false
    t.string   "perishable_token",                                 :null => false
    t.integer  "login_count",         :default => 0,               :null => false
    t.integer  "failed_login_count",  :default => 0,               :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin"
    t.string   "name"
    t.integer  "facebook_uid"
    t.string   "subscription_plan",   :default => "Bitspace Free"
    t.integer  "max_storage",         :default => 1073741824
  end

end
