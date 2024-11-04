# frozen_string_literal: true

module ScriptErrors
  class ScriptError < ::StandardError; end

  # Used to alert the user that an invalid flag has been detected. Reminds user
  # what the valid flags are.
  class InvalidFlagError < ScriptError
    def initialize(input:, position:, acceptable:)
      super("\nInvalid flag '#{input}' passed in position #{position}. \nAcceptable flags are: #{acceptable}")
    end
  end

  class FlagAssignmentError < ScriptError
    def initialize
      super("\nInvalid Flag Assignment. \nThe flags '-h' and '--help' are reserved by the Command class.")
    end
  end

  class InputError < ScriptError; end

  class ResponseError < ScriptError; end
end
