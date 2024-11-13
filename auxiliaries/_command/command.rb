# frozen_string_literal: true

require_relative 'parameter_handler'
require_relative 'flag_handler'
require_relative 'prompter'
require_relative 'command_errors'
require_relative 'filer'
require_relative 'shorthand'
require_relative 'inspector_aux/main'
require_relative 'class_extensions'
require_relative 'keyword_handler'

# Where the command was summoned from.
CALL_PATH = Dir.pwd

Dir.chdir

# The user's home directory
HOME_PATH = Dir.pwd
# Where the Commands themselves are
MAIN_PATH = "#{HOME_PATH}/commands"
# The Command Class's aux folder, which holds all the other aux folders
AUXILIARIES_PATH = "#{MAIN_PATH}/auxiliaries"

# @todo This is getting out of hand.
#   Instead of having stages in which everything is processed at the same time, it should be organized
#   by what is being processed. Flags, Keywords then parameters. I've also decided on a strictness hierarchy:
#   1. Flags - the most strict. These are for hard functionality and state changes.
#   2. Keywords - more flexibility. Use to attach input to a specific state change (instead of being positional)
#   3. Parameters - Least strict. Anyting else the user submits
#   There should also a module for checking user input (import from Cho Han). i.e
#   def await_specific_input { |answer, program_state| break if true }; end
# The base class for all shell commands.
class Command
  include KeywordHandler
  include ParameterHandler
  include FlagHandler
  include CommandErrors
  include Prompter
  include Filer
  include Shorthand

  private

  HELP_OPTIONS = %w[-h --help -i --inspect].freeze
  INPUT_KEYS = %i[flags parameters keywords].freeze

  attr_writer :inputs, :received, :accepted,
              :assigned_options, :assigned_keywords,
              :options, :flag_limit, :parameter_limit,
              :execution_path, :case_sensitivity

  # @param argv [Array] This should always be ARGV
  # @param flag_limit [Range] The minimum and maximum number of flags kept by the mint.
  # @param parameter_limit [Range] The maximum number of parameters kept by the mint.
  # @param case_sensitive [Boolean, Symbol]
  def initialize(argv, flag_limit: (0..1), parameter_limit: (0..1), case_sensitive: false)
    # EXAMPLE: These must show up in each child class's initialize method before calling super.
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
    inspect if received[:flags].any? { |flag| HELP_OPTIONS[2..3].include? flag }
  end

  def normalize_case_sensitivity(settings)
    settings.is_a?(Array) ? settings : [settings]
  end

  def initialize_hashes
    self.assigned_options ||= Hash.new(0)
    self.assigned_keywords ||= Hash.new(0)

    self.received = Hash.new { |hash, key| hash[key] = [] }
    INPUT_KEYS.each { |key| received[key] }

    received[:keywords] = Hash.new(0)
  end

  def clamp_range(range, bounds: (0...10))
    ([range.begin, bounds.min].max..[range.end, bounds.max].min)
  end

  def process_inputs
    create_options_array
    receive_inputs
    accept_inputs
    help if received[:flags].any? { |flag| HELP_OPTIONS[0..1].include? flag }
  end

  def receive_inputs
    receive_possible_flags
    receive_possible_keywords
    receive_possible_parameters
  end

  def accept_inputs
    create_acceptance_hash

    accepted_flags
    accept_keywords
    accept_parameters
    return if case_sensitivity.first == true

    INPUT_KEYS[0..1].each do |key|
      accepted[key].map!(&:downcase) if case_sensitivity == false || !case_sensitivity.include?(key)
    end
  end

  def create_acceptance_hash
    original_proc = received.default_proc
    procless = received.dup
    procless.default_proc = nil

    self.accepted = Marshal.load(Marshal.dump(procless))

    accepted.default_proc = original_proc
  end

  # Prints the command's help file.
  def help
    initialize_execution_path # @todo get rid of this

    puts File.empty?('help.txt') ? "Valid Options: #{options}" : File.read('help.txt')

    exit
  end

  def initialize_execution_path
    self.execution_path = "#{AUXILIARIES_PATH}/#{self.class.to_s.downcase}_aux"
    Dir.chdir(execution_path)
  end

  public

  attr_reader :inputs, :received, :accepted,
              :assigned_options, :assigned_keywords,
              :options, :flag_limit, :parameter_limit,
              :execution_path, :case_sensitivity

  def run
    # In child classes: 'super' should be at the top
    # If flag validation is not necessary, dont use 'super'
    validate_flags unless options.empty?
  end

  def inspect
    Inspector.new(self)
  end
end
