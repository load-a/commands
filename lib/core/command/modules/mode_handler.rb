# frozen_string_literal: true

module ModeHandler
  MANDATORY_OPTIONS = {
    bypass: 'b+', # Use in development to bypass Mode Check
    configure: 'c+',
    help: 'h+',
    inspect: 'i+',
    reset: 'r+'
  }.freeze

  # MODE PATTERN (letters can be upper- or lowercase)
  # short flags: one dash; one to three letters; an optional plus sign
  # long flags: two dashes; any letter; one or more letters, numbers or underscores
  MODE_PATTERN = /(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/.freeze

  def generate_options
    if options.nil?
      self.options = MANDATORY_OPTIONS.dup 
    else
      self.options.merge! MANDATORY_OPTIONS.dup
    end

    options.each do |mode, flag|
      flags = Normalize.to_array flag
      
      flags.map! { |flag| Normalize.to_flag flag }
      flags << Normalize.to_flag(mode.to_s, type: :long)

      options[mode] = flags.select {|flag| MODE_PATTERN =~ flag}
    end
  end

  def matches_mode?(string)
    MODE_PATTERN =~ string
  end

  def cull_modes
    # tokens[:modes].uniq! # This wont cull variations of the same mode (i.e. '--default' and '-def')
    tokens[:modes].slice!(settings[:mode_limit].max..-1)
  end

  def verify_mode_tokens
    tokens[:modes].each do |token|
      raise CommandErrors::InvalidFlagError.new(token, options) unless flags.include? token
    end
  end

  def flags
    options.values.flatten
  end

  def establish_mode
    verify_mode_tokens
    transform_modes
    update_mode
  end

  def transform_modes
    tokens[:modes].map! do |token|
      options.each { |mode, flags| break mode if flags.include? token }
    end

    tokens[:modes].uniq!
  end

  def update_mode
    if tokens[:modes].empty?
      state[:modes] = Normalize.to_array(settings[:default_mode])
    else
      state[:modes] = tokens[:modes]
    end

    partition_modes
  end

  def partition_modes
    core_modes, input_modes = state[:modes].partition { |mode| MANDATORY_OPTIONS.keys.include? mode }
    state[:settings][:core_modes] = core_modes
    state[:settings][:input_modes] = input_modes
  end
end
