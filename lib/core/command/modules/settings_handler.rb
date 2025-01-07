# frozen_string_literal: true

module SettingsHandler
  # SETTING_PATTERN
  # One or more word characters; a colon; one or more word characters
  SETTING_PATTERN = %r{\w+:[\w/.-]+}.freeze

  # This needs to override everything else.
  MANDATORY_SETTINGS = {
    active_mode: nil,
    core_modes: [],
    input_modes: [],
    case_sensitivity: [:parameters],
    default_mode: :inspect,
    mode_limit: (0..2),
    parameter_limit: (1..9),
    execution_directory: nil,
    send_directory: nil
  }.freeze

  def generate_settings
    self.settings = MANDATORY_SETTINGS.dup if settings.nil?

    self.settings = MANDATORY_SETTINGS.dup.merge settings
  end

  def matches_setting?(string)
    SETTING_PATTERN =~ string
  end

  def verify_settings_tokens
    tokens[:settings].each do |token|
      puts "invalid config: #{token}" unless valid_setting_string? token
    end
  end

  def valid_setting_string?(config)
    key = config.split(':')[0].to_sym

    settings.keys.include?(key) || all_adjustment_keys.include?(key)
  end

  def all_adjustment_keys
    keys = []
    
    adjustments.each do |key, value|
      value.each do |k, v|
        keys << k
      end
    end

    keys
  end

  def cull_settings; end

  def transform_settings
    setting_hash = {}

    tokens[:settings].each do |token|
      name, value = token.split(':', 2)
      setting_hash[name.to_sym] = Normalize.from_string(value)
    end

    tokens[:settings] = setting_hash
  end
end
