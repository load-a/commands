# frozen_string_literal: true

require 'dir_req'

# Require needed directories (like normal)
DirReq.require_directory '/Users/saramir/commands/lib/core/command/modules'
DirReq.require_directory '/Users/saramir/commands/lib/core/command/errors'
DirReq.require_directory '/Users/saramir/commands/lib/core/extensions'

class Command
  include ModeHandler
  # MODE PATTERN (letters can be upper- or lowercase)
  # short flags: one dash; one to three letters; an optional plus sign
  # long flags: two dashes; any letter; one or more letters, numbers or underscores
  MODE_PATTERN = /(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/.freeze
  # CONFIG_PATTERN
  # One or more word characters; a colon; one or more word characters
  CONFIG_PATTERN = %r{\w+:[\w/.-]+}.freeze

  # This needs to override everything else.
  MANDATORY_SETTINGS = {
    wait: nil,
    case_sensitivity: [:parameters],
    default_mode: :inspect,
    mode_limit: (0..1),
    parameter_limit: (1..9),
    execution_directory: nil,
    send_directory: nil,
    adjustments: {}
  }.freeze

  # Should probably not be a constant
  MANDATORY_ADJUSTMENTS = {
    configure: {},
    bypass: {},
    help: {},
    inspect: {},
    reset: {}
  }.freeze

  attr_accessor :raw, :tokens, :state,
                :options, :configurations, :adjustments,
                :default_options, :default_settings, :default_adjustments,
                :mode

  def initialize(argv = [])
    set_default_attributes

    update_from_input argv
  end

  def set_default_attributes
    check_for_duplicate_options

    generate_options

    generate_configurations
    reset_state
  end

  def reset_state
    self.state = {
      modes: [],
      configurations: configurations,
      parameters: []
    }
  end

  def check_for_duplicate_options
    return if options.nil?

    all_flags = []

    options.each_value do |flags|
      flags.each do |flag|
        all_flags << Normalize.to_flag(flag)
      end
    end
  end

  def generate_options
    self.options = MANDATORY_OPTIONS.dup if options.nil?

    options.each do |mode, flag|
      flags = Normalize.to_array flag
      flags.map! { |flag| Normalize.to_flag flag }
      flags << Normalize.to_flag(mode.to_s, type: :long)
      options[mode] = flags
    end
  end

  def flags
    options.values.flatten
  end

  def generate_configurations
    self.configurations = MANDATORY_SETTINGS.dup if configurations.nil?

    generate_adjustments

    self.configurations = MANDATORY_SETTINGS.dup.merge configurations

    configurations[:adjustments] = adjustments
  end

  def generate_adjustments
    self.adjustments = MANDATORY_ADJUSTMENTS.dup if adjustments.nil?

    adjustments.merge! MANDATORY_ADJUSTMENTS.dup
  end

  def update_from_input(input)
    self.raw = input
    normalize_raw_input
    sort_raw_input
    check_input_limits
    cull_tokens
    verify
    transform
    update

    enforce_defaults
  end

  def enforce_defaults; end

  def normalize_raw_input
    Normalize.to_array raw
    raw.map! { |element| element.to_s }
  end

  def sort_raw_input
    case_sensitivity = self[:case_sensitivity]

    reset_token_stream

    raw.each do |element|
      element = element.downcase if case_sensitivity == false

      if MODE_PATTERN =~ element
        element = element.downcase unless case_sensitivity == true || case_sensitivity.include?(:modes)
        tokens[:modes] << element
      elsif CONFIG_PATTERN =~ element
        element = element.downcase unless case_sensitivity == true || case_sensitivity.include?(:configurations)
        tokens[:configurations] << element
      else
        element = element.downcase unless case_sensitivity == true || case_sensitivity.include?(:parameters)
        tokens[:parameters] << element
      end
    end
  end

  def reset_token_stream
    self.tokens = {
      modes: [],
      configurations: [],
      parameters: []
    }
  end

  def check_input_limits
    raise 'NOT ENOUGH MODES' if configurations[:mode_limit].min > tokens[:modes].length
  end

  def cull_tokens
    cull_modes
    cull_configurations
    cull_parameters
  end

  def cull_modes
    tokens[:modes].uniq! # This wont cull variations of the same mode (i.e. '--default' and '-def')
    tokens[:modes].slice!(configurations[:mode_limit].max..-1)
  end

  def cull_configurations; end

  def cull_parameters
    tokens[:parameters].slice!(configurations[:parameter_limit].max..-1)
  end

  def verify
    tokens[:modes].each do |token|
      raise "INVALID FLAG: #{token}\nOPTIONS: #{options}" unless flags.include? token
    end

    tokens[:configurations].each do |token|
      puts "invalid config: #{token}" unless valid_config_string? token
    end

    tokens[:configurations].reject! { |token| !valid_config_string?(token) }
  end

  def valid_config_string?(config)
    configurations.keys.include? config.split(':')[0].to_sym
  end

  def transform
    tokens[:modes].map! do |token|
      options.each { |mode, flags| break mode if flags.include? token }
    end

    tokens[:modes].uniq!

    config_hash = {}

    tokens[:configurations].each do |token|
      name, value = token.split(':', 2)
      config_hash[name.to_sym] = Normalize.from_string(value)
    end

    tokens[:configurations] = config_hash
  end

  def update
    reset_state

    state[:modes] += tokens[:modes]
    state[:configurations].merge! tokens[:configurations]
    state[:parameters] += tokens[:parameters]

    state[:modes] = Normalize.to_array(self[:default_mode].to_sym) if state[:modes].empty?

    self.mode = state[:modes].first
  end

  def parameters
    state[:parameters]
  end

  def [](symbol)
    state[:configurations][symbol]
  end

  def configure
    puts 'CONFIGURATION MODE:', configurations # Change config file
  end

  def help
    puts 'HELP MODE:', options # system "cat #{COMMANDS_PATH}/#{self.class.to_s.downcase}/help.md"
  end

  def inspect
    puts 'INSPECTION MODE:', "RAW: #{raw}", "TOKENS: #{tokens}", "STATE: #{state}"
  end

  def reset
    puts 'RESET MODE:'
    # Reset config file
  end

  def run
    send(mode) if MANDATORY_OPTIONS.keys.include?(mode) && mode != :bypass
  end
end
