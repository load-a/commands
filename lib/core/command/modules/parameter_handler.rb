# frozen_string_literal: true

module ParameterHandler
  def cull_parameters
    tokens[:parameters].slice!(settings[:parameter_limit].max..-1)
  end
  
  def each_parameter(method_symbol = nil)
    parameters.each do |parameter|
      if method_symbol
        method(method_symbol).call(parameter)
      else
        yield parameter
      end
    end
  end
end
