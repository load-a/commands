# frozen_string_literal: true

module InputHandler
  def update_from_input(input)
    self.raw = input

    preprocess_inputs
    reset_state
    establish_mode # The mode will set the context for everything else

    settings.merge! adjustments[mode]

    verify
    transform_settings
    update
    enforce_default_settings
  end

  def preprocess_inputs
    normalize_raw_input
    sort_raw_input
    check_input_limits
    cull_tokens
  end

  def enforce_default_settings; end

  def normalize_raw_input
    Normalize.to_array raw
    raw.map! { |element| element.to_s }
  end

  def sort_raw_input
    case_sensitivity = self[:case_sensitivity]

    reset_token_stream

    raw.each do |element|
      element = element.downcase if case_sensitivity == false

      if matches_mode?(element)
        element = element.downcase unless case_sensitivity == true || case_sensitivity.include?(:modes)
        tokens[:modes] << element
      elsif matches_setting?(element)
        element = element.downcase unless case_sensitivity == true || case_sensitivity.include?(:settings)
        tokens[:settings] << element
      else
        element = element.downcase unless case_sensitivity == true || case_sensitivity.include?(:parameters)
        tokens[:parameters] << element
      end
    end
  end

  def reset_token_stream
    self.tokens = {
      modes: [],
      settings: [],
      parameters: []
    }
  end

  def check_input_limits
    raise 'NOT ENOUGH MODES' if settings[:mode_limit].min > tokens[:modes].length
  end

  def cull_tokens
    cull_modes
    cull_settings
    cull_parameters
  end

  def verify
    verify_settings_tokens
    
    tokens[:settings].reject! { |token| !valid_setting_string?(token) }
  end

  def update
    raise "Mode is nil" if mode.nil?

    state[:settings].merge! adjustments[mode]
    state[:settings].merge! tokens[:settings]

    state[:parameters] += tokens[:parameters]
  end
end
