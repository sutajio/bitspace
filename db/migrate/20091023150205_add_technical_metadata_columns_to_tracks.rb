class AddTechnicalMetadataColumnsToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :bitrate, :integer
    add_column :tracks, :samplerate, :integer
    add_column :tracks, :vbr, :boolean
    add_column :tracks, :content_type, :string
  end

  def self.down
    remove_column :tracks, :bitrate
    remove_column :tracks, :samplerate
    remove_column :tracks, :vbr
    remove_column :tracks, :content_type
  end
end
