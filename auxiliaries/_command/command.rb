# frozen_string_literal: true

require_relative 'class_extensions'

# Where the command was summoned from.
CALL_PATH = Dir.pwd

Dir.chdir

# The user's home directory
HOME_PATH = Dir.pwd
# Where the Commands themselves are
MAIN_PATH = "#{HOME_PATH}/commands"
# The Command Class's aux folder, which holds all the other aux folders
AUXILIARIES_PATH = "#{MAIN_PATH}/auxiliaries"

module Normalize
  module_function

  def to_array(object, flatten: false)
    return [] if object.nil?

    if flatten
      [object].flatten
    else
      object.is_a?(Array) ? object : [object]
    end
  end

  def from_array(array)
    array.length == 1 ? array.first : array
  end

  def from_string(string)
    if string.numeric?
      string.to_i
    elsif %w[true false].include?(string.downcase)
      (string == 'true')
    else
      string
    end
  end
end

class Command
  MODE_PATTERN = /(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/.freeze
  SETTING_PATTERN = /\w+:\w+/.freeze
  REQUIRED_OPTIONS = {
    help: 'h',
    inspect: 'i'
  }.freeze
  BASE_SETTINGS = {
    case_sensitive: [true],
    execution_directory: nil, # Where the events of the program think they are
    send_directory: nil, # Where (if anywhere) the values of the program should be sent,
    empty_return: nil # What you want to be returned in case of an empty result (experimental),
  }.freeze

  attr_accessor :raw, :valid, :processed,
                :modes, :settings, :parameters,
                :default_options, :default_settings, # user modes and settings respectively
                :options, :keywords, # ALL options or settings
                :execution_directory, :send_directory

  def initialize(argv)
    # Assign SETTINGS and MODES up top

    # Just the raw input from ARGV
    self.raw = argv.dup # make it so new inputs get added to this?

    # All valid pattern matches, categorized (plus any default settings)
    # @todo Deal with possible nil values
    self.valid = {
      modes: raw.grep(MODE_PATTERN),
      settings: raw.grep(SETTING_PATTERN),
      parameters: raw.reject { |word| word =~ MODE_PATTERN || word =~ SETTING_PATTERN }
    }

    self.execution_directory = "#{AUXILIARIES_PATH}/_#{self.class.to_s.downcase}" # @todo CORRECT THIS AFTER TESTING
    self.send_directory = execution_directory.dup

    # @todo Merge into user defined settings later
    default_settings[:execution_directory] ||= execution_directory
    default_settings[:send_directory] ||= send_directory

    # Options dont get merged into input modes. Its an independent list
    default_options.merge REQUIRED_OPTIONS

    self.default_settings = BASE_SETTINGS.dup.merge(default_settings.compact)

    # Valid values that pass review (plus any default settings)
    self.processed = {
      modes: [],
      settings: {},
      parameters: []
    }

    self.options = []
    self.keywords = {}

    default_options.each do |key, value|
      options << "--#{key}"
      options << (value.start_with?('-') ? value : "-#{value}")
    end

    self.keywords = default_settings.keys

    # UPDATE - act on user input here (redefine settings, select mode, etc.)
  end

  def change_directories
    unless processed[:settings][:execution_directory].nil?
      self.execution_directory = processed[:settings][:execution_directory]
    end

    self.send_directory = processed[:settings][:send_directory] unless processed[:settings][:send_directory].nil?

    Dir.chdir execution_directory
  end

  def get_modes
    validate_modes
    process_modes
  end

  def validate_modes
    valid[:modes]
  end

  def process_modes
    valid[:modes].each do |mode|
      mode = mode.downcase if convert_to_downcase?(:modes)
      processed[:modes] << mode if options.include?(mode)
    end
  end

  def convert_to_downcase?(type)
    !(default_settings[:case_sensitive].include?(type) ||
        default_settings[:case_sensitive] == [true])
  end

  def get_settings
    validate_settings
    process_settings
  end

  # POSSIBLY NOT NEEDED
  def validate_settings
    # valid[:settings].each do |setting|
    #   key, value = setting.split(':', 2)
    #   # raise "cannot overwrite default settings" if @_default_settings.include?(key)
    #   valid[:settings][key] = value
    # end
    #
    # valid[:settings].merge default_settings unless valid[:settings] == default_settings
  end

  def process_settings
    valid[:settings].each do |key_pair|
      key_pair = key_pair.downcase if convert_to_downcase?(:settings)
      key, value = key_pair.split(':', 2)
      processed[:settings][key.to_sym] = Normalize.from_string(value) if keywords.include? key.to_sym
    end
  end

  def process_parameters
    processed[:parameters] = if convert_to_downcase?(:parameters)
                               valid[:parameters].map(&:downcase)
                             else
                               valid[:parameters]
                             end
  end

  def inspect
    # show inspection screen
  end

  def help
    # Show help screen
  end

  def output
    converted_settings = processed[:settings].map do |key, value|
      "#{key}:#{value}"
    end

    converted_parameters = processed[:parameters].map do |parameter|
      format '"%s"', parameter
    end

    "#{processed[:modes].join(' ')} #{converted_settings.join(' ')} #{converted_parameters.join(' ')}"
  end

  def run
    get_modes
    get_settings
    process_parameters

    type = :none
    puts "TYPE: #{type}", "RAW: #{raw}", "VALID: #{valid}",
         "PROCESSED: #{processed}"
    puts "OPTIONS: #{options}", "KEYWORDS: #{keywords}", "CASE: #{default_settings[:case_sensitive]}",
         "OUTPUT: #{output}"
  end
end
