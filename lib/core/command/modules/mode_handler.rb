# frozen_string_literal: true

module ModeHandler
  REQUIRED_OPTIONS = {
      help: 'h',
      inspect: 'i'
  }.freeze

  attr_accessor :options

  def initialize_modes
    self.default_options ||= REQUIRED_OPTIONS.dup
    self.default_options = if default_options == REQUIRED_OPTIONS
                             default_options
                           else
                             default_options.merge(REQUIRED_OPTIONS)
                           end

    self.options = []

    default_options.each do |key, value|
      options << "--#{key}"
      options << Normalize.to_flag(value)
    end
  end

  alias update_modes initialize_modes

  def process_modes
    processed[:modes] = if convert_to_downcase?(:modes)
                          valid[:modes].map(&:downcase)
                        else
                          valid[:modes]
                        end

    processed[:modes].reject! { |mode| options.none? mode }

    processed[:modes].slice!((settings[:mode_limit].max..-1))
  end

  def modes
    Normalize.from_array processed[:modes]
  end

  def check_mode(name_symbol)
    return false unless options.include?(Normalize.to_flag(name_symbol.to_s))

    processed[:modes].any? do |flag|
      flag == Normalize.to_flag(name_symbol.to_s, type: :verbose) ||
          Normalize.to_array(default_options[:name_symbol]).include?(flag)
    end
  end
end
