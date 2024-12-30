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
    enforce_directives
  end

  def preprocess_inputs
    normalize_raw_input
    sort_raw_input
    check_for_mode_tokens
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

  def check_for_mode_tokens
    modes_found = tokens[:modes].length
    modes_needed = settings[:mode_limit]
    
    unless modes_needed.include? modes_found
      raise CommandErrors::InputError.new('Modes', modes_found, modes_needed) 
    end
  end

  def cull_tokens
    cull_settings
    cull_parameters
  end

  def verify
    verify_settings_tokens
    
    tokens[:settings].reject! { |token| !valid_setting_string?(token) }
  end

  def update
    raise CommandErrors::InvalidModeError.new('Nil') if mode.nil?

    merge_settings

    state[:settings].merge! tokens[:settings]

    state[:parameters] = tokens[:parameters]
  end

  def merge_settings
    if state[:settings][:active_mode]
      state[:settings].merge! adjustments[state[:settings][:active_mode]]
    else
      state[:settings].merge! adjustments[mode]
    end
  end
end
