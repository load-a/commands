module ParameterHandler
  private

  def receive_parameters
    is_a_keyword = inputs.grep(/\w+:\w+/)
    received[:parameters] = (inputs.dup - (received[:flags] + is_a_keyword)) || []

    return if received[:parameters].length >= parameter_limit.min

    raise InputQuantityError.new('Parameters', received[:parameters], parameter_limit)
  end

  def accept_parameters
    accepted[:parameters] = received[:parameters].dup
    accepted[:parameters].slice!((parameter_limit.max..-1))

    return if parameter_limit.include? accepted[:parameters].length

    raise InputQuantityError.new 'Parameters', received[:parameters], parameter_limit.min
  end
end
