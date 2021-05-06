class AddLockedAttributeToInstallationConfig < ActiveRecord::Migration[6.0]
  def up
    unless column_exists? :installation_configs, :locked
      add_column :installation_configs, :locked, :boolean, default: true, null: false
    end
    purge_duplicates
    add_index :installation_configs, :name, unique: true
  end

  def down
    if column_exists? :installation_configs, :locked
      remove_column :installation_configs, :locked
    end
    remove_index :installation_configs, :name
  end

  def purge_duplicates
    config_names = InstallationConfig.all.map(&:name).uniq

    config_names.each do |name|
      ids = InstallationConfig.where(name: name).pluck(&:id)
      next if ids.size <= 1

      # preserve the last config and destroy rest
      ids.sort!
      ids.pop
      InstallationConfig.where(id: ids).destroy_all
    end
  end
end
