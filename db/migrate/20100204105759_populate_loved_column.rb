class PopulateLovedColumn < ActiveRecord::Migration
  def self.up
    Track.find_each do |track|
      track.update_attribute(:loved_at, track.playlist_items.present? ? track.playlist_items.first.created_at: nil)
    end
  end

  def self.down
    Track.find_each do |track|
      track.update_attribute(:loved_at, nil)
    end
  end
end
