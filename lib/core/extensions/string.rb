# frozen_string_literal: true

class ::String
  # Checks if self is a valid number.
  # Checks for Decimal, Scientific Notation, Binary, Hex and octal.
  def numeric?
    match?(/\A-?\d+(\.\d+)?(e-?\d+)?\z/i) || match?(/\A-?(0b[01]+|0[0-7]+|0x[\da-f]+)\z/i)
  end

  def to_numeric(default = 0)
    case self
    when /\A-?0o?[0-7]+\z/i # Match valid octal numbers
      to_i(8)
    when /\A-?\d+\z/i # Match valid decimal integers
      to_i
    when /\A-?\d+\.\d+\z/i # Match floats
      to_f
    when /\A-?\d+(\.\d+)?e-?\d+\z/i # Match scientific notation
      Float(self)
    when /\A-?0b[01]+\z/i # Match binary
      to_i(2)
    when /\A0x[\da-f]+\z/i # Match hexadecimal
      to_i(16)
    else
      default
    end
  end
end
