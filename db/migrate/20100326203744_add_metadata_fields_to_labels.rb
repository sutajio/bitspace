class AddMetadataFieldsToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :sort_name, :string
    add_column :labels, :type, :string
    add_column :labels, :begin_date, :date
    add_column :labels, :end_date, :date
    add_column :labels, :website, :string
    add_column :labels, :tags, :string
  end

  def self.down
    remove_column :labels, :sort_name
    remove_column :labels, :type
    remove_column :labels, :begin_date
    remove_column :labels, :end_date
    remove_column :labels, :website
    remove_column :labels, :tags
  end
end
