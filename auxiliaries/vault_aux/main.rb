# frozen_string_literal: true

require_relative '../_command/command'

class Vault < Command
  def initialize(argv, option_range: (0..1), parameter_range: (0..1), case_sensitive: false)
    self.assigned_options = {
      # verbose: 'simple', (dash is optional)
      # verbose: w%[simple_1, simple_2]
    }
    super
  end

  def run
    super
    # Add code here
  end
end
