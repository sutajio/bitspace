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

ActiveRecord::Schema.define(:version => 20100116222349) do

  create_table "artists", :force => true do |t|
    t.string   "mbid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "releases_count"
    t.integer  "user_id"
    t.string   "artwork_file_name"
    t.string   "artwork_content_type"
    t.integer  "artwork_file_size"
    t.datetime "artwork_updated_at"
  end

  add_index "artists", ["mbid"], :name => "index_artists_on_mbid"
  add_index "artists", ["name"], :name => "index_artists_on_name"
  add_index "artists", ["releases_count"], :name => "index_artists_on_releases_count"
  add_index "artists", ["user_id"], :name => "index_artists_on_user_id"

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.boolean  "published"
    t.string   "slug"
    t.integer  "year"
    t.integer  "month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_versions", :force => true do |t|
    t.integer  "client_id"
    t.string   "version"
    t.text     "release_notes"
    t.integer  "downloads"
    t.string   "signature"
    t.string   "download_file_name"
    t.string   "download_content_type"
    t.integer  "download_file_size"
    t.datetime "download_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "invitation_requests", :force => true do |t|
    t.string   "email"
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
    t.string   "subscription_id"
    t.string   "subscription_plan"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "invitations", ["token"], :name => "index_invitations_on_token"

  create_table "labels", :force => true do |t|
    t.string   "mbid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "artwork_file_name"
    t.string   "artwork_content_type"
    t.integer  "artwork_file_size"
    t.datetime "artwork_updated_at"
  end

  add_index "labels", ["mbid"], :name => "index_labels_on_mbid"
  add_index "labels", ["name"], :name => "index_labels_on_name"
  add_index "labels", ["user_id"], :name => "index_labels_on_user_id"

  create_table "playlist_items", :force => true do |t|
    t.integer  "playlist_id"
    t.integer  "user_id"
    t.integer  "track_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "playlist_items", ["playlist_id"], :name => "index_playlist_items_on_playlist_id"
  add_index "playlist_items", ["track_id"], :name => "index_playlist_items_on_track_id"
  add_index "playlist_items", ["user_id"], :name => "index_playlist_items_on_user_id"

  create_table "playlists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "playlists", ["name"], :name => "index_playlists_on_name"

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
    t.integer  "user_id"
    t.date     "release_date"
    t.integer  "tracks_count"
    t.boolean  "archived",             :default => false
  end

  add_index "releases", ["archived"], :name => "index_releases_on_archived"
  add_index "releases", ["artist_id"], :name => "index_releases_on_artist_id"
  add_index "releases", ["label_id"], :name => "index_releases_on_label_id"
  add_index "releases", ["mbid"], :name => "index_releases_on_mbid"
  add_index "releases", ["title"], :name => "index_releases_on_title"
  add_index "releases", ["user_id"], :name => "index_releases_on_user_id"
  add_index "releases", ["year"], :name => "index_releases_on_year"

  create_table "scrobbles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "track_id"
    t.datetime "started_playing"
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
    t.integer  "user_id"
    t.integer  "set_nr"
  end

  add_index "tracks", ["artist_id"], :name => "index_tracks_on_artist_id"
  add_index "tracks", ["fingerprint"], :name => "index_tracks_on_fingerprint"
  add_index "tracks", ["mbid"], :name => "index_tracks_on_mbid"
  add_index "tracks", ["release_id"], :name => "index_tracks_on_release_id"
  add_index "tracks", ["title"], :name => "index_tracks_on_title"
  add_index "tracks", ["track_nr"], :name => "index_tracks_on_track_nr"
  add_index "tracks", ["user_id"], :name => "index_tracks_on_user_id"

  create_table "uploads", :force => true do |t|
    t.integer  "user_id"
    t.string   "bucket"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "facebook_uid"
    t.string   "name"
    t.string   "email"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                       :default => 0
    t.integer  "failed_login_count",                :default => 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.boolean  "is_admin"
    t.string   "subscription_id"
    t.string   "subscription_plan",                 :default => "Bitspace Free"
    t.integer  "max_storage",         :limit => 20, :default => 524288000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lastfm_session_key"
    t.string   "lastfm_username"
    t.boolean  "lastfm_subscriber"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
  end

  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"

end
