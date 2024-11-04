# frozen_string_literal: true

# Used to communicate with the user. It asks questions and records answers,
# usually of the yes-or-no variety.
module Prompter
  AFFIRMATIVE = %w[y yes yeah ok sure yep 1 yea].freeze
  NEGATIVE = %w[n no nope nah nay 0].freeze

  # Prints question to the screen and gets user response.
  # @return [String] The user's response.
  def ask(question, first_word: false)
    puts question
    listen(first_word: first_word)
  end

  # @param first_word [Boolean] Only uses the first word of the string.
  # @return [String]
  def listen(first_word: false)
    response = gets.split.map(&:downcase)
    first_word ? response.first : response.join(' ')
  end

  # Asks a question and returns whether the answer was a valid "yes" response.
  # @return [Boolean]
  def confirm?(question = 'Are you sure? (y/n)')
    AFFIRMATIVE.include? ask(question, first_word: true)
  end

  alias confirm confirm?
end
