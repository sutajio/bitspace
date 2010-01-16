class AddArtworkToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :artwork_file_name,    :string
    add_column :labels, :artwork_content_type, :string
    add_column :labels, :artwork_file_size,    :integer
    add_column :labels, :artwork_updated_at,   :datetime
  end

  def self.down
    remove_column :labels, :artwork_file_name
    remove_column :labels, :artwork_content_type
    remove_column :labels, :artwork_file_size
    remove_column :labels, :artwork_updated_at
  end
end
