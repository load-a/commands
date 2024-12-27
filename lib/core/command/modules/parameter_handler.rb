# frozen_string_literal: true

module ParameterHandler
  def cull_parameters
    tokens[:parameters].slice!(settings[:parameter_limit].max..-1)
  end
end
