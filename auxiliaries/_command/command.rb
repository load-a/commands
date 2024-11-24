# frozen_string_literal: true

require_relative 'class_extensions/class_extensions'
require_relative 'modules/command_modules'

# Where the command was summoned from.
CALL_PATH = Dir.pwd

Dir.chdir

# The user's home directory
HOME_PATH = Dir.pwd
# Where the Commands themselves are
MAIN_PATH = "#{HOME_PATH}/commands"
# The Command Class's aux folder, which holds all the other aux folders
AUXILIARIES_PATH = "#{MAIN_PATH}/auxiliaries"

class Command
  include ParameterHandler
  include KeywordHandler
  include ModeHandler

  MODE_PATTERN = /(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/.freeze
  SETTING_PATTERN = /\w+:\w+/.freeze

  attr_accessor :raw, :valid, :processed,
                # :modes, :settings, :parameters,
                :default_options, :default_settings, # user modes and settings respectively
                :execution_directory, :send_directory

  def initialize(argv)
    # Assign SETTINGS and MODES up top

    # Just the raw input from ARGV
    self.raw = argv.dup # make it so new inputs get added to this?

    # All valid pattern matches in raw input
    self.valid = {
        modes: raw.grep(MODE_PATTERN),
        settings: raw.grep(SETTING_PATTERN),
        parameters: raw.reject { |word| word =~ MODE_PATTERN || word =~ SETTING_PATTERN }
    }

    self.execution_directory, self.send_directory =
        Array.new(2) do
          # @todo CORRECT THIS AFTER TESTING
          "#{AUXILIARIES_PATH}/_#{self.class.to_s.downcase}"
        end

    initialize_settings
    initialize_modes

    # Valid data that meets various criteria and undergoes processing
    self.processed = {
        modes: [],
        settings: {},
        parameters: []
    }

    # UPDATE - act on user input here (redefine settings, select mode, etc.)
  end

  def change_directories
    unless processed[:settings][:execution_directory].nil?
      self.execution_directory = processed[:settings][:execution_directory]
    end

    self.send_directory = processed[:settings][:send_directory] unless processed[:settings][:send_directory].nil?

    Dir.chdir execution_directory
  end

  def convert_to_downcase?(type)
    !(default_settings[:case_sensitive].include?(type) ||
        default_settings[:case_sensitive] == [true])
  end

  def inspect
    # show Inspection screen
  end

  def help
    # Show help screen
  end

  def run
    get_modes
    get_settings
    process_parameters
  end
end
