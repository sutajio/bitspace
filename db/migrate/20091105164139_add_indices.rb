class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :artists, :mbid
    add_index :artists, :name
    add_index :artists, :releases_count
    add_index :invitations, :token
    add_index :labels, :mbid
    add_index :labels, :name
    add_index :playlist_items, :playlist_id
    add_index :playlist_items, :user_id
    add_index :playlist_items, :track_id
    add_index :playlists, :name
    add_index :releases, :artist_id
    add_index :releases, :label_id
    add_index :releases, :mbid
    add_index :releases, :title
    add_index :releases, :year
    add_index :tracks, :release_id
    add_index :tracks, :artist_id
    add_index :tracks, :fingerprint
    add_index :tracks, :mbid
    add_index :tracks, :title
    add_index :tracks, :track_nr
    add_index :users, :facebook_uid
  end

  def self.down
    remove_index :artists, :mbid
    remove_index :artists, :name
    remove_index :artists, :releases_count
    remove_index :invitations, :token
    remove_index :labels, :mbid
    remove_index :labels, :name
    remove_index :playlist_items, :playlist_id
    remove_index :playlist_items, :user_id
    remove_index :playlist_items, :track_id
    remove_index :playlists, :name
    remove_index :releases, :artist_id
    remove_index :releases, :label_id
    remove_index :releases, :mbid
    remove_index :releases, :title
    remove_index :releases, :year
    remove_index :tracks, :release_id
    remove_index :tracks, :artist_id
    remove_index :tracks, :fingerprint
    remove_index :tracks, :mbid
    remove_index :tracks, :title
    remove_index :tracks, :track_nr
    remove_index :users, :facebook_uid
  end
end
