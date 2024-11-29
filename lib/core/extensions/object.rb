# frozen_string_literal: true

class ::Object
  # Returns its own class.
  # @return [Class]
  def this
    self.class
  end

  # Returns its own parent class.
  # @return [Class]
  def parent
    self.class.superclass
  end
end
