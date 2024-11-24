module ModeHandler
  REQUIRED_OPTIONS = {
    help: 'h',
    inspect: 'i'
  }.freeze

  attr_accessor :options

  def initialize_modes
    self.default_options = default_options.merge REQUIRED_OPTIONS

    self.options = []

    default_options.each do |key, value|
      options << "--#{key}"
      options << (value.start_with?('-') ? value : "-#{value}")
    end
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

    processed[:modes].slice!((settings[:mode_limit].max..-1))
  end

  def modes
    processed[:modes]
  end
end
