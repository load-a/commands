# frozen_string_literal: true

# Handles Configuration File interactions between the specified vault and the Maser Config Folder
module Configs
  # Replaces this vault's config with the Master Config Folder.
  def pull_config(vault_folder)
    vault_name = File.basename(vault_folder).gsub('\\', '')
    vault_config = "#{vault_folder}/.obsidian"
    pull_warning = [
      "Replace #{vault_name}'s config folder with the Master Config folder?",
      "(This will DELETE the current vault's settings.)"
    ].join("\n")

    return unless confirm? pull_warning

    system "rm -r #{vault_config}"
    system "cp -r #{MASTER_CONFIG_FOLDER}/ #{vault_config}"
  end

  # Replaces the master config folder with this vault's config folder.
  def push_config(vault_folder)
    vault_name = File.basename(vault_folder).gsub('\\', '')
    vault_config = "#{vault_folder}/.obsidian"
    push_warning = [
      "Update the Master Config folder with #{vault_name}'s config folder?",
      '(This will DELETE the current Master Config settings.)'
    ].join("\n")

    return unless confirm? push_warning

    system "rm -r #{MASTER_CONFIG_FOLDER}"
    system "cp -r #{vault_config}/ #{MASTER_CONFIG_FOLDER}"
  end
end
