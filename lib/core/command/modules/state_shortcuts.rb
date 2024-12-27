# frozen_string_literal: true

module StateShortcuts
  def parameters
    state[:parameters]
  end

  def [](symbol)
    state[:settings][symbol]
  end

  def []=(symbol, value)
    state[:settings][symbol] = value
  end

  def mode
    state[:modes].first
  end

  def each_mode
    self[:input_modes].each do |mode|
      state[:settings][:active_mode] = mode
      update

      yield mode
    end
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
