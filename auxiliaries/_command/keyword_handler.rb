# frozen_string_literal: true

module KeywordHandler
  def receive_possible_keywords
    reception = inputs.grep(/\w+:\w+/)
    return received[:keywords] = [] if reception.empty?

    reception.map!(&:downcase) unless case_sensitivity.include?(:keywords)

    reception.each do |key_pair|
      key, value = key_pair.split(':', 2)
      received[:keywords][key.to_sym] = value
    end
  end

  def accept_keywords
    received[:keywords].each do |keyword, value|
      next unless assigned_keywords.keys.include? keyword

      accepted[:keywords][keyword] = if value.numeric?
                                       value.to_i
                                     elsif %w[true false].include?(value)
                                       (value == 'true')
                                     else
                                       value
                                     end
    end
  end
end
