# frozen_string_literal: true

require_relative 'prompter'
require_relative 'command_errors'
require_relative 'filer'
require_relative 'shorthand'

# Where the command was summoned from.
CALL_PATH = Dir.pwd

Dir.chdir

# The user's home directory
HOME_PATH = Dir.pwd
# Where the Commands themselves are
MAIN_PATH = "#{HOME_PATH}/commands"
# The Command Class's aux folder, which holds all the other aux folders
AUXILIARIES_PATH = "#{MAIN_PATH}/auxiliaries"

# The base class for all shell commands.
class Command
  include CommandErrors
  include Prompter
  include Filer
  include Shorthand

  private

  HELP_OPTIONS = %w[-h --help].freeze
  INPUT_KEYS = %i[flags parameters keywords].freeze

  attr_writer :inputs, :received, :found,
              :option_assignments, :keyword_assignments,
              :options, :flag_limit, :parameter_limit,
              :execution_path, :case_sensitivity

  # @param argv [Array] This should always be ARGV
  # @param flag_limit [Range] The minimum and maximum number of flags kept by the mint.
  # @param parameter_limit [Range] The maximum number of parameters kept by the mint.
  # @param case_sensitive [Boolean, Symbol]
  def initialize(argv, flag_limit: (0..1), parameter_limit: (0..1), case_sensitive: false)
    # These must show up in each child class's initialize method before calling super.
    #
    # self.option_assignments = {
    #   test_flag_one: 'flg',
    #   test_flag_two: 'tf+'
    # }
    #
    # self.keyword_assignments = {
    # word: 'Explanation',
    # other_word: 'Other explanation'
    # }
    #
    # super
    #
    self.inputs = argv.dup

    self.case_sensitivity = normalize_case_sensitivity(case_sensitive)

    initialize_hashes

    self.flag_limit = clamp_range flag_limit
    self.parameter_limit = clamp_range parameter_limit

    process_inputs

    initialize_execution_path

    ARGV.clear # Must be cleared to allow for future user input
  end

  def normalize_case_sensitivity(settings)
    settings.is_a?(Array) ? settings : [settings]
  end

  def initialize_hashes
    self.option_assignments ||= Hash.new(0)
    self.keyword_assignments ||= Hash.new(0)

    self.received = Hash.new { |hash, key| hash[key] = [] }
    INPUT_KEYS.each { |key| received[key] }

    self.found = received.dup
    found[:keywords] = Hash.new(0)
  end

  def clamp_range(range, bounds: (0...10))
    ([range.begin, bounds.min].max..[range.end, bounds.max].min)
  end

  def process_inputs
    define_all_options
    extract_received_inputs
    find_inputs
    help if received[:flags].any? { |flag| HELP_OPTIONS.include? flag }
  end

  # Takes the valid flag hash from initialization and extracts every valid
  # flag from it
  # @return [Void]
  def define_all_options
    return self.options = [] if option_assignments.empty?

    option_assignments.each do |verbose, simple|
      options << "--#{verbose}"
      options << simple.start_with?('-') ? simple : "-#{simple}"
    end

    raise FlagAssignmentError if options.any? { |flag| HELP_OPTIONS.include? flag }

    self.options += HELP_OPTIONS
  end

  def extract_received_inputs
    extract_possible_flags
    extract_possible_keywords
    extract_possible_parameters
  end

  def extract_possible_flags
    # Simple flags can be 1 to 3 letters long and can optionally end with a '+'
    # Verbose flags must start with a double hyphen followed by a letter.
    #   It can thereafter have any number of letters, underscores or numbers

    received[:flags] = inputs.grep(/(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/) || []

    return if received[:flags].length >= flag_limit.min

    raise InputQuantityError.new('Flags', received[:flags], flag_limit)
  end

  def extract_possible_keywords
    received[:keywords] = inputs.grep(/\w+:\w+/) || []
  end

  def extract_possible_parameters
    received[:parameters] = (inputs.dup - (received[:flags] + received[:keywords])) || []

    return if received[:parameters].length >= parameter_limit.min

    raise InputQuantityError.new('Parameters', received[:parameters], parameter_limit)
  end

  def find_inputs
    find_flags
    find_keywords
    find_parameters
    return if case_sensitivity.first == true

    INPUT_KEYS[0..1].each do |key|
      found[key].map!(&:downcase) if case_sensitivity == false || !case_sensitivity.include?(key)
    end
  end

  def find_flags
    return if options.empty?

    found[:flags] = received[:flags].dup
    found[:flags].slice!(flag_limit.max..-1)

    return if flag_limit.include? found[:flags].length

    raise InputError, "Insufficient flags; Minimum required: #{flag_limit.min}"
  end

  def find_keywords
    received_keys = received[:keywords].dup
    received_keys.map!(&:downcase) unless case_sensitivity.include?(:keywords)

    received_keys.each do |received_key|
      found_key, value = received_key.split(':', 2)
      found[:keywords][found_key.to_sym] = value
    end
  end

  def find_parameters
    found[:parameters] = received[:parameters].dup
    found[:parameters].slice!((parameter_limit.max..-1))

    return if parameter_limit.include? found[:parameters].length

    raise InputQuantityError.new 'Parameters', received[:parameters], parameter_limit.min
  end

  # Prints the command's help file.
  def help
    initialize_execution_path

    puts File.empty?('help.txt') ? "Valid Options: #{options}" : File.read('help.txt')

    exit
  end

  def initialize_execution_path
    self.execution_path = "#{AUXILIARIES_PATH}/#{self.class.to_s.downcase}_aux"
    Dir.chdir(execution_path)
  end

  def validate_flags
    found[:flags].each do |found_flag|
      raise InvalidFlagError.new(**flag_error_packet(found_flag)) unless options.include? found_flag
    end
  end

  def flag_error_packet(erroneous_flag)
    {
      input: erroneous_flag,
      position: inputs.index(erroneous_flag),
      acceptable: options
    }
  end

  public

  attr_reader :inputs, :received, :found,
              :option_assignments, :keyword_assignments,
              :options, :flag_limit, :parameter_limit,
              :execution_path, :case_sensitivity

  def run
    # In child classes: 'super' should be at the top
    # If flag validation is not necessary, dont use 'super'
    validate_flags unless options.empty?
  end
end
