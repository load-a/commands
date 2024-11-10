# frozen_string_literal: true

require_relative '../_command/command'
require_relative 'constants'

# Plays a Wordle-like game.
class Wurdle < Command
  KEYS = %w[
    Q W E R T Y U I O P
    A S D F G H J K L
    Z X C V B N M
  ].freeze

  attr_accessor :word, :number_of_guesses, :wrong_letters, :found_letters, :revealed_letters

  def initialize(argv, flag_limit: (0..0), parameter_limit: (0..2), case_sensitive: false)
    self.option_assignments = Hash.new(0)

    super

    self.word = parameters[0]
    self.number_of_guesses = parameters[1].to_i.clamp(1..9) if parameters.length > 1

    self.word = WORDS.sample if word == 'random' || parameters.empty?
    self.word = word.upcase

    self.number_of_guesses ||= word.length + 1

    self.wrong_letters = []
    self.found_letters = []
    self.revealed_letters = Array.new(word.length, '_')
  end

  def run
    super

    puts opening_line

    loop do
      guess = ask("What is your guess? (#{number_of_guesses + 1})").upcase[...word.length]

      next puts word_count_warning if guess.length < word.length

      break puts 'You Win!' if guess == word
      break puts 'you lose...' if number_of_guesses.zero?

      self.number_of_guesses -= 1
      puts status(guess)
    end

    reveal_word
  end

  def opening_line
    "#{'_ ' * word.length}\n#{word.length} letters, #{number_of_guesses} guesses."
  end

  def word_count_warning
    "Guess must be at least #{word.length} characters\n"
  end

  def status(guess)
    [
      "\n#{check_letters(guess)}\n\n",
      "```\n#{revealed_letters.join(' ')}\n",
      "Found letters: #{found_letters}\n",
      "#{keyboard(wrong_letters)}\n```"
    ]
  end

  def reveal_word
    puts "Today's word: #{word}"
  end

  def check_letters(guess)
    correct_word = word.chars
    guess = guess.chars

    markdown_display = []

    guess.each_with_index do |letter, position|
      found_letters << letter if correct_word.include?(letter) && !found_letters.include?(letter)
      revealed_letters[position] = '_' unless correct_word[position] == letter
      revealed_letters[position] = ' ' if word[position] == ' '

      markdown_display << if correct_word[position] == letter
                            revealed_letters[position] = letter
                            "**#{letter}**"
                          elsif correct_word.include?(letter)
                            "*#{letter}*"
                          else
                            wrong_letters << letter unless wrong_letters.include? letter
                            "~~#{letter}~~"
                          end
    end

    wrong_letters.sort!
    found_letters.sort!

    markdown_display.join(' ')
  end

  def keyboard(wrong_letters)
    keys = KEYS.dup

    keys.map! do |letter|
      if wrong_letters.include?(letter)
        '_'
      elsif found_letters.include? letter
        letter.upcase
      else
        letter.downcase
      end
    end

    (keys[0...10] + ["\n"] + keys[10...19] + ["\n "] + keys[19..]).join(' ')
  end
end