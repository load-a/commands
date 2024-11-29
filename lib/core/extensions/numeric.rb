# frozen_string_literal: true

class ::Numeric
  def round_up(increment = 10)
    return self if (self % increment).zero?

    self + increment - (self % increment)
  end

  def round_down(increment = 10)
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

  def divisible_by?(divisor)
    raise ZeroDivisionError if divisor.zero?
    (self % divisor).zero?
  end
end
