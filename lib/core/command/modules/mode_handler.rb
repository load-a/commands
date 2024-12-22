# frozen_string_literal: true

module ModeHandler
  MANDATORY_OPTIONS = {
    bypass: 'b+', # Use in development to bypass Default Mode Check
    configure: 'c+',
    help: 'h+',
    inspect: 'i+',
    reset: 'r+'
  }.freeze
end
