class CreateClientVersions < ActiveRecord::Migration
  def self.up
    create_table :client_versions do |t|
      t.belongs_to :client
      t.string :version
      t.text :release_notes
      t.integer :downloads
      t.string :signature
      t.string :download_file_name
      t.string :download_content_type
      t.integer :download_file_size
      t.datetime :download_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :client_versions
  end
end
