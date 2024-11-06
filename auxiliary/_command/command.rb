# frozen_string_literal: true

require_relative 'prompter'
require_relative 'script_errors'
require_relative 'filer'

# Where the command was summoned from.
ORIGINAL_PATH = Dir.pwd

Dir.chdir

# The user's home directory
HOME_PATH = Dir.pwd

# Where the Commands themselves are
MAIN_PATH = "#{HOME_PATH}/commands"

# The Command Class's aux folder, which holds all the other aux folders
MAIN_AUX_PATH = "#{MAIN_PATH}/auxiliary"

# The base class for all shell commands.
class Command
  # @todo Make it possible and easy to handle multiple positions with specific valid flags
  include ScriptErrors
  include Prompter
  include Filer

  HELP_OPTIONS = %w[-h --help].freeze

  attr_reader :inputs, :flag_inputs, :argument_inputs, :option_assignments,
              :options, :option_range, :parameter_range, :flags,
              :arguments

  # @note In child classes: first define all valid flags as a Hash in which the
  #   keys are the verbose flags and the values are the abbreviated ones.
  #   Define the command directory here as well.
  # @param argv [Array] This should always be ARGV
  # @param option_range [Range] The minimum and maximum number of flags kept by the make.
  # @param parameter_range [Range] The maximum number of arguments kept by the make.
  def initialize(argv, option_range: (0..1), parameter_range: (0..1), case_sensitive: false)
    self.inputs = argv.dup
    inputs.map!(&:downcase) unless case_sensitive

    set_input_ranges(option_range, parameter_range)

    process_inputs

    set_and_move_to_class_path

    ARGV.clear # Must be cleared to allow for future user input
  end

  private

  attr_writer :inputs, :flag_inputs, :argument_inputs, :option_assignments,
              :options, :option_range, :parameter_range, :flags,
              :arguments

  def set_input_ranges(options, parameters)
    self.option_range = (([options.min, 0].max)..[options.max, 9].min)
    self.parameter_range = ([parameters.min, 0].max..[parameters.max, 9].min)
  end

  # Prints the command's help file.
  def help
    set_and_move_to_class_path
    puts File.empty?('help.txt') ? "Valid Options: #{options}" : File.read('help.txt')

    exit
  end

  def process_inputs
    define_options
    detect_inputs
    accept_inputs
  end

  def detect_inputs
    detect_input_flags
    detect_input_arguments
  end

  def detect_input_flags
    # Simple flags can be 1 to 3 letters long and can optionally end with a '+'
    # Verbose flags must start with a double hyphen and can be 1 or more letters long.
    # Flags are NOT case sensitive by default.
    self.flag_inputs = inputs.grep(/(\B-[A-Za-z]{1,3}\+?\b)|(^--[A-Za-z]+$)/)

    help if !flag_inputs.nil? && flag_inputs.any? { |flag| HELP_OPTIONS.include? flag }

    return if option_range.include? flag_inputs.length

    error_message = [
        "Invalid number or type of inputs: #{inputs}",
        "Flags: #{option_assignments} (#{option_range})",
        "Args: (#{parameter_range})"
    ]

    raise InputError, error_message
  end

  def detect_input_arguments
    self.argument_inputs = inputs.reject { |input| flag_inputs.include? input }
    return if parameter_range.include? argument_inputs.length

    raise InputError, "Wrong number of input arguments #{argument_inputs}: #{argument_inputs.length} / #{parameter_range}"
  end

  # Takes the valid flag hash from initialization and extracts every valid
  # flag from it
  # @return [Void]
  def define_options
    self.options = option_assignments.keys.map { |key| "--#{key}" } +
        option_assignments.values.flatten.map { |value| value.start_with?('-') ? value : "-#{value}" }

    raise FlagAssignmentError if options.any? { |flag| HELP_OPTIONS.include? flag }

    self.options += HELP_OPTIONS
  end

  def accept_inputs
    accept_flags
    accept_arguments
  end

  def accept_flags
    return self.flags = [] if flag_inputs.nil?
    return self.flags = flag_inputs if flag_inputs.empty?

    extraction_range = option_range.map { |i| i - 1 }
    extraction_range = (extraction_range.min..extraction_range.max)

    self.flags = flag_inputs[extraction_range]

    raise InputError, "Input flags not valid: #{flag_inputs}" unless option_range.include? flags.length

    self.flags = flags[0] if flags.length == 1
  end

  def accept_arguments
    return self.arguments = [] if argument_inputs.nil? || argument_inputs.empty?

    minimum = [parameter_range.min - 1, 0].max
    maximum = [parameter_range.max - 1, 9].min
    extraction_range = (minimum..maximum)

    self.arguments = argument_inputs[extraction_range]
    self.arguments = arguments[0] if arguments.length == 1
  end

  def valid_flag?(flag)
    options.include? flag
  end

  def validate_flags
    if flags.is_a?(String)
      return if valid_flag? flags

      raise InvalidFlagError.new(**flag_error_packet(flags))
    end

    flags.each do |check_flag|
      raise InvalidFlagError.new(**flag_error_packet(check_flag)) unless valid_flag? check_flag
    end
  end

  def flag_error_packet(flag)
    {
        input: flag,
        position: inputs.index(flag),
        acceptable: options
    }
  end

  def set_and_move_to_class_path
    # Class Path is the path for the child class's auxiliary folder
    @class_path = "#{MAIN_AUX_PATH}/#{self.class.to_s.downcase}_aux"
    Dir.chdir(@class_path)
  end

  def run
    # In child classes: 'super' should be at the top
    # If flag validation is not necessary, dont use 'super'
    validate_flags
  end
end
