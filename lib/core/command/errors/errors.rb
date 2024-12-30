# frozen_string_literal: true

module CommandErrors
  class CommandError < StandardError; end
  class QuantityError < CommandError; end

  class InputError < QuantityError 
    def initialize(entity, quantity, requirement) 
      super "Not enough #{entity} \nFound: #{quantity} \nNeed: #{requirement}"
    end
  end

  class InvalidModeError < CommandError
    def initialize(mode_found)
      super "Invalid Mode: #{mode_found}"
    end
  end

  class InvalidFlagError < CommandError
    def initialize(flag_found, options)

      super "Invalid flag: #{flag_found} \nOptions: \n#{options}"
    end
  end
end
