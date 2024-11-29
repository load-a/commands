module ParameterHandler
  def process_parameters
    processed[:parameters] = if convert_to_downcase?(:parameters)
                               valid[:parameters].map(&:downcase)
                             else
                               valid[:parameters]
                             end
    processed[:parameters].slice!((settings[:parameter_limit].max..-1))
  end

  def parameters
    Normalize.from_array processed[:parameters]
  end
end
