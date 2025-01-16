# frozen_string_literal: true

module Prompter
  AFFIRMATIVE = %w[yes y yep yup yeah affirmative sure certainly definitely indeed okay ok right correct absolutely aye agreed true roger positive unquestionably ye yea]

  NEGATIVE = %w[no n nope nah negative never not nix nada nay]


  def listen
    ARGV.clear # Important! Old input could get reread otherwise
    gets.chomp.downcase
  end

  def say(text)
    puts text
  end

  def ask(question = "What do you say?")
    say question
    listen
  end

  alias answer_to ask

  def confirm?(question = "Are you sure? y/n")
    AFFIRMATIVE.include? answer_to "#{question} (y/n)"
  end

  alias said_yes_to? confirm?
  alias yes? confirm?

  def deny?(question = 'Do you mind? n/y')
    NEGATIVE.include answer_to "#{question} (y/n)"
  end

  alias said_no_to? deny?
  alias no? deny?
end
