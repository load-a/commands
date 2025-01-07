# frozen_string_literal: true

class ::Numeric
  def round_up(increment = 10)
    raise "Cannot round up by increments of Zero" if increment.zero?

    return self if (self % increment).zero?

    self + increment - (self % increment)
  end

  def round_down(increment = 10)
    raise "Cannot round down by increments of Zero" if increment.zero?
    
    return self if (self % increment).zero?

    self - (self % increment)
  end

  def not_positive?
    self <= 0
  end

  def not_negative?
    self >= 0
  end

  def not_zero?
    self != 0
  end

  def divisible_by?(divisor, error: true)
    raise ZeroDivisionError if divisor.zero? && error

    return false if divisor.zero?

    (self % divisor).zero?
  end

  def natural_number?(include_zero: false, integer_value: false, tolerance: 1e-10)
    return false if integer_value && (to_i - self).abs > tolerance

    (include_zero ? not_negative? : positive?) && (integer_value || is_a?(Integer))
  end
end
