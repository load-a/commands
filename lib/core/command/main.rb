# frozen_string_literal: true

require 'dir_req'

# Record from where the command was called.
CALL_PATH = Dir.pwd

# Move to home directory.
Dir.chdir

# Record user's home directory.
HOME_PATH = Dir.pwd

# Create other Path Constants.
require_relative 'paths'

# Require needed directories (like normal)
DirReq.require_directory CORE_DIRECTORY,
                         ignore: DirReq.collect_file_paths(DEPRECATED_PATH),
                         load_first: COMMAND_MAIN

# Go back to where the command was called. [This is important for development.]
Dir.chdir CALL_PATH

class Command
  include ModeHandler
  include ParameterHandler
  include SettingsHandler

  MODE_PATTERN = /(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/.freeze
  SETTING_PATTERN = /\w+:\w+/.freeze

  attr_accessor :raw, :valid, :processed,
                # :modes, :settings, :parameters,
                :default_options, :default_settings, # user modes and settings respectively
                :execution_directory, :send_directory

  def initialize(argv = [])
    # Assign SETTINGS and MODES up top

    # Just the raw input from ARGV
    self.raw = argv.dup # make it so new inputs get added to this?

    # All valid pattern matches in raw input
    self.valid = {
        modes: raw.grep(MODE_PATTERN),
        settings: raw.grep(SETTING_PATTERN),
        parameters: raw.reject { |word| word =~ MODE_PATTERN || word =~ SETTING_PATTERN }
    }

    self.execution_directory = if self.class == Command
                                 COMMAND_DIRECTORY
                               else
                                 "#{COMMANDS_PATH}/#{self.class.to_s.downcase}"
                               end

    self.send_directory = execution_directory

    assign_default_settings
    initialize_modes

    # Valid data that meets various criteria and undergoes processing
    self.processed = {
        modes: [],
        settings: {},
        parameters: []
    }

    # UPDATE - act on user input here (redefine settings, select mode, etc.)
  end

  # @note THIS MUST ONLY BE USED WHEN NEEDED. OTHERWISE STAY IN THE CALL PATH
  def change_directories
    unless processed[:settings][:execution_directory].nil?
      self.execution_directory = processed[:settings][:execution_directory]
    end

    self.send_directory = processed[:settings][:send_directory] unless processed[:settings][:send_directory].nil?

    Dir.chdir execution_directory
  end

  def convert_to_downcase?(type)
    state = Normalize.from_array settings[:case_sensitive]

    return !state if [TrueClass, FalseClass].include?(state.class)

    settings[:case_sensitive].none?(type)
  end

  def inspect
    # show Inspection screen
  end

  def help
    # system "cat #{COMMANDS_PATH}/#{self.class.to_s.downcase}/help.md"
  end

  def run
    # update these two
    update_modes
    update_settings

    process_modes
    process_settings
    process_parameters
  end
end
