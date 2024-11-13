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

  def divisible_by?(other)
    (self % other).zero?
  end
end

class ::Object
  def this
    self.class
  end

  def parent
    superclass
  end
end

class ::String
  def numeric?
    return false unless self =~ /^\d+$/

    to_i.to_s == self ||
      to_f.to_s == self ||
      if start_with? '-'
        to_i(2).to_s(2).sub('-', '-0b') == self ||
          to_i(8).to_s(8).sub('-', '-0') == self ||
          to_i(16).to_s(16).sub('-', '-0x') == self
      else
        "0b#{to_i(2).to_s(2)}" == self ||
          "0#{to_i(8).to_s(8)}" == self ||
          "0x#{to_i(16).to_s(16)}" == self
      end
  end
end
