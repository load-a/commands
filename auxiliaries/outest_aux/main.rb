# frozen_string_literal: true

require_relative '../_command/command'

class Outest < Command
  def initialize(argv)
    self.default_options = {
      new: 'n',
      old: 'o'
    }

    self.default_settings = {
      shape: 'the kind of shape',
      volume: 'the volume of shape',
      case_sensitive: [false]
    }
    super
  end
end
