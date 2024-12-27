# frozen_string_literal: true

module StateShortcuts
  def parameters
    state[:parameters]
  end

  def [](symbol)
    state[:settings][symbol]
  end

  def mode
    state[:modes].first
  end
end
