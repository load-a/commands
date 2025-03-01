# frozen_string_literal: true

require 'shellwords'

require_relative '../../core/command/main'

DirReq.require_directory "#{File.dirname(__FILE__)}/modules"

# Handles the creation and usage of Obsidian vaults.
class Vault < Command
  include Backups
  include Configs

  OBSIDIAN_FOLDER = "#{Dir.home}/Desktop/Obsidian"
  MASTER_CONFIG_FOLDER = "#{OBSIDIAN_FOLDER}/.obsidian"

  def initialize(argv = [])
    self.options = {
      make: %w[m mk new w --new --write --create],
      remove: %w[r rm d del --delete],
      rename: %w[n mv rn --name --move],
      update: %w[u get --pull --get], # update own config from central
      push: %w[p --push --give], # overwrite config in central,
      save: %w[s],
      load: 'l'
    }

    self.settings = {
      execution_directory: File.dirname(__FILE__),
      send_directory: OBSIDIAN_FOLDER,
      default_mode: :make,
      case_sensitivity: %i[parameters],
      parameter_limit: (0..2),
      mode_limit: (0..2)
    }

    self.adjustments = {}
    options.each_key { |option| adjustments[option] = {} }

    self.directives = {
      execution_directory: File.dirname(__FILE__),
      send_directory: OBSIDIAN_FOLDER,
      case_sensitivity: %i[parameters]
    }

    super
  end

  # Creates a new vault with a single file, and the current configurations found in the Master Config folder.
  def make_vault(vault_folder)
    vault_name = File.basename(vault_folder)

    raise 'Vault already exists' if Dir.exist? vault_folder

    system "mkdir #{vault_folder}"
    system "cp -r #{MASTER_CONFIG_FOLDER} #{vault_folder}/.obsidian"
    system "touch #{vault_folder}/#{vault_name}.md" # Creates a default file

    system "cp -r #{OBSIDIAN_FOLDER}/.templates/ #{vault_folder}/templates" # Copies master templates folder

    puts "Made #{vault_name.gsub('\\', '')}"
  end

  # Deletes a vault and all of its contents.
  def remove_vault(vault_folder)
    vault_name = File.basename(vault_folder).gsub('\\', '')

    return puts "Vault: #{vault_name} does not exist." unless Dir.exist? vault_folder.gsub('\\', '')

    return unless confirm? "Are you sure you want to get rid of this vault: #{vault_name}?"

    system "rm -r #{vault_folder}"
    puts "Removed #{vault_name}"
  end

  # Changes the name of the vault folder only (not the names of any files)
  def rename_vault(old_path, new_name)
    new_path = "#{File.dirname(old_path)}/#{new_name}"

    return unless confirm? "Rename #{old_path.gsub('\\', '')} -> #{new_path}"

    system "mv #{old_path} #{Shellwords.escape(new_path)}"
    puts "Changed #{old_path} -> #{new_path}"
  end

  def run
    super

    vault_folder = "#{OBSIDIAN_FOLDER}/#{Shellwords.escape(parameters.first)}" # precaution against names with spaces

    case mode
    when :make
      make_vault vault_folder
    when :remove
      remove_vault vault_folder
    when :rename
      check_for_parameters(2)

      new_name = parameters[1]

      rename_vault vault_folder, new_name
    when :update
      pull_config vault_folder
    when :push
      push_config vault_folder
    when :save
      save_config vault_folder
    when :load
      load_config vault_folder
    end
  end
end
