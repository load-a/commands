# frozen_string_literal: true

module SettingsHandler
  BASE_SETTINGS = {
      case_sensitive: Normalize.to_array(true),
      parameter_limit: (0..1),
      mode_limit: (0..1),
      execution_directory: nil, # Where the events of the program think they are
      send_directory: nil, # Where (if anywhere) the values of the program should be sent,
      empty_return: nil # What you want to be returned in case of an empty result (experimental),
  }.freeze

  def assign_default_settings
    self.default_settings ||= BASE_SETTINGS.dup
    default_settings[:execution_directory] ||= execution_directory
    default_settings[:send_directory] ||= send_directory
    self.default_settings = BASE_SETTINGS.dup.merge(default_settings.compact)
  end

  def update_settings
    # Case Sensitivity
    unless settings[:case_sensitive].is_a?(Array)
      if processed[:settings].include?(:case_sensitive)
        processed[:settings][:case_sensitive] = Normalize.from_string(processed[:settings][:case_sensitive])
        processed[:settings][:case_sensitive] = Normalize.to_array(processed[:settings][:case_sensitive])
      else
        default_settings[:case_sensitive] = Normalize.from_string(default_settings[:case_sensitive])
        default_settings[:case_sensitive] = Normalize.to_array(default_settings[:case_sensitive])
      end
    end
  end

  def keywords
    settings.keys
  end

  def process_settings
    valid[:settings].each do |key_pair|
      key_pair = key_pair.downcase if convert_to_downcase?(:settings)
      key, value = key_pair.split(':', 2)
      processed[:settings][key.to_sym] = Normalize.from_string(value) if keywords.include? key.to_sym
    end

    update_settings
  end

  def settings
    default_settings.merge processed[:settings]
  end
end
