# frozen_string_literal: true

module AdjustmentHandler
  MANDATORY_ADJUSTMENTS = {
    bypass: {},
    configure: {},
    help: {},
    inspect: {},
    reset: {}
  }.freeze

  def generate_adjustments
    self.adjustments = MANDATORY_ADJUSTMENTS.dup if adjustments.nil?

    adjustments.merge! MANDATORY_ADJUSTMENTS.dup
  end
end
