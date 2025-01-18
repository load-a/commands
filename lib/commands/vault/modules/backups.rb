# frozen_string_literal: true

# Handles saving and loading a vault's configuration backup folder
module Backups
  # Copies the config files from the .obsidian folder into a .backup folder.
  def save_config(vault_path)
    vault_path = vault_path_or_master(vault_path)
    obsidian_folder, backup_folder = backup_paths(vault_path)

    return if vault_path == OBSIDIAN_FOLDER && !confirm?('Backup the Master Config Folder?')

    return if Dir.exist?(backup_folder.gsub('\\', '')) && !confirm?('Overwrite current backup config?')

    system "cp -r #{obsidian_folder}/ #{backup_folder}"
    puts "Saved current configurations into #{backup_folder}"
  end

  # Copies the config files from .backup
  def load_config(vault_path)
    vault_path = vault_path_or_master(vault_path)
    obsidian_folder, backup_folder = backup_paths(vault_path)

    return 'Backup does not exist' unless Dir.exist? backup_folder

    confirmation_message = if vault_path == OBSIDIAN_FOLDER
                             'Restore the Master Config Folder from backup?'
                           else
                             'Overwrite current Obsidian Configurations?'
                           end

    return unless confirm? confirmation_message

    system "cp -r #{backup_folder}/ #{obsidian_folder}"
    puts "Loaded backup into #{obsidian_folder}"
  end

  def vault_path_or_master(vault_path)
    vault_path.end_with?("''") ? OBSIDIAN_FOLDER : vault_path
  end

  def backup_paths(vault_path)
    ["#{vault_path}/.obsidian", "#{vault_path}/.backup"]
  end
end
