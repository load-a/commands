# frozen_string_literal: true

module SettingsHandler
  BASE_SETTINGS = {
      case_sensitive: [true],
      parameter_limit: (0..1),
      mode_limit: (0..1),
      execution_directory: nil, # Where the events of the program think they are
      send_directory: nil, # Where (if anywhere) the values of the program should be sent,
      empty_return: nil # What you want to be returned in case of an empty result (experimental),
  }.freeze

  def initialize_settings
    self.default_settings ||= BASE_SETTINGS.dup
    default_settings[:execution_directory] ||= execution_directory
    default_settings[:send_directory] ||= send_directory

    self.default_settings = BASE_SETTINGS.dup.merge(default_settings.compact)
  end

  def keywords
    default_settings.keys
  end

  def process_settings
    valid[:settings].each do |key_pair|
      key_pair = key_pair.downcase if convert_to_downcase?(:settings)
      key, value = key_pair.split(':', 2)
      processed[:settings][key.to_sym] = Normalize.from_string(value) if keywords.include? key.to_sym
    end
  end

  def settings
    default_settings.merge processed[:settings]
  end
end
