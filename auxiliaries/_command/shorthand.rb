# frozen_string_literal: true

module Shorthand
  # Gets the size of the array. If it is exactly 1, it returns the object as is.
  # Otherwise, it will output the complete array.
  def simplify(array)
    if array.length == 1
      array.first
    else
      array
    end
  end

  # The following methods now call the attribute and simplify it.
  # Therefore, if you want to explicitly work with an array you can just use the hash,
  # else if you want to work with the values call these methods

  def flags
    simplify found[:flags]
  end

  def parameters
    simplify found[:parameters]
  end

  def keywords
    found[:keywords] # This is a Hash; no simplification.
  end

  def received_flags
    simplify received[:flags]
  end

  def received_parameters
    simplify received[:parameters]
  end

  def received_keywords
    simplify received[:keywords]
  end
end
