# frozen_string_literal: true

module KeywordHandler
  def receive_keywords
    reception = inputs.grep(/\w+:\w+/)
    return received[:default_settings] = [] if reception.empty?

    reception.map!(&:downcase) unless case_sensitivity.include?(:default_settings)

    reception.each do |key_pair|
      key, value = key_pair.split(':', 2)
      received[:default_settings][key.to_sym] = value
    end
  end

  def accept_keywords
    received[:default_settings].each do |keyword, value|
      next unless settings_list.keys.include? keyword

      accepted[:default_settings][keyword] = if value.numeric?
                                               value.to_i
                                             elsif %w[true false].include?(value)
                                               (value == 'true')
                                             else
                                               value
                                             end
    end
  end
end
