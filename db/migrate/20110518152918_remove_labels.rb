class RemoveLabels < ActiveRecord::Migration
  def self.up
    add_column :releases, :label_name, :string
    Label.find_each do |label|
      label.releases.each do |release|
        release.label_name = label.name
        release.save!
      end
    end
    rename_column :releases, :label_name, :label
  end

  def self.down
    remove_column :releases, :label
  end
end
