# frozen_string_literal: true

module CommandErrors
  class CommandError < ::StandardError; end

  # Used to alert the user that an invalid flag has been detected. Reminds user
  # what the valid flags are.
  class InvalidFlagError < CommandError
    def initialize(input:, position:, acceptable:)
      super("\nInvalid flag '#{input}' passed in position #{position}. \nAcceptable flags are: #{acceptable}")
    end
  end

  class FlagAssignmentError < CommandError
    def initialize
      super("\nInvalid Flag Assignment. \nThe flags '-h' and '--help' are reserved by the Command class.")
    end
  end

  class InputError < CommandError; end

  class InputQuantityError < InputError
    def initialize(name, received, limit)
      super("Wrong number of #{name}:\n#{received} (#{received.length} / #{limit})")
    end
  end

  class ResponseError < InputError; end
end
