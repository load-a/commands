# frozen_string_literal: true

require_relative '../_command/command'

class Outest < Command
  def initialize(argv, flag_limit: (0..1), parameter_limit: (0..1), case_sensitive: false)
    self.assigned_options = {
      # verbose: 'simple', (dash is optional)
      # verbose: w%[simple_1, simple_2]
    }
    self.assigned_keywords = {
      int: 'Any integer',
      string: 'Any string',
      boolean: 'Any boolean'
    }
    super
  end

  def run
    super
    inspect
    puts '. . . '
    puts received[:keywords] == accepted[:keywords]
  end

  def uses_flag?(flag)
    received[:flags].include?(flag)
  end

  def uses_keyword?(keyword)
    accepted[:keywords].include?(keyword)
  end
end
