# frozen_string_literal: true

require_relative '../../core/command/main'

DirReq.require_directory "#{File.dirname(__FILE__)}/modules"

class Chohan < Command
  def initialize(argv = [])
    self.options = {}

    self.settings = {
      default_mode: :bypass,
      send_directory: Dir.pwd,
      case_sensitivity: %i[settings parameters],
      parameter_limit: (0..0),
      mode_limit: (0..1)
    }

    self.adjustments = {}

    self.directives = {
      execution_directory: File.dirname(__FILE__),
      case_sensitivity: %i[false]
    }

    @screen = ""
    @cash = 0

    @high_scores = [
      ["Alice", 50],
      ["Bob", 48],
      ["Charlie", 47],
      ["Diana", 45],
      ["Ethan", 44],
      ["Fiona", 43],
      ["George", 42],
      ["Hannah", 41],
      ["Ian", 39],
      ["Jenna", 38],
      ["Kevin", 37],
      ["Laura", 36],
      ["Michael", 34],
      ["Nora", 33],
      ["Oscar", 32],
      ["Paula", 30],
      ["Quinn", 29],
      ["Rachel", 27],
      ["Simon", 25],
      ["Tina", 22]
    ]

    @high_score_name_limit = 16

    super
  end

  def roll_dice
    [rand(1..6), rand(1..6)]
  end

  def blank_screen
    system "printf '\33c\e[3J'"
  end

  def update_screen(dice, guess)
    @screen = File.read 'screens/game.txt'

    resolve_round(dice, guess).each do |datum, value|
      @screen.sub!(datum.to_s.upcase, value.to_s)
    end

    @screen = @screen.split("\n").flatten.map {|line| line.center(31)}.join("\n")
  end

  def resolve_round(dice, guess)
    sum = dice.sum
    result = {
      die1: dice[0],
      die2: dice[1],
      sum: sum,
      difference: -(dice[0] - dice[1]).abs,
      result: sum.even? ? 'even' : 'odd',
      guess: guess,
      cash: @cash
    }

    status = resolve_result_and_winnings(result, guess)

    @cash += status[:winnings]

    result.merge! status

    result
  end

  def resolve_result_and_winnings(result, guess)
    win_text = "You win!"
    lose_text = "You lose."

    if (result[:result] == guess) 
      {winnings: 1, status: win_text}
    elsif guess == result[:die1] || guess == result[:die2]
      {winnings: 3, status: win_text}
    elsif guess == "#{result[:difference]}"
      {winnings: 5, status: win_text}
    elsif guess == "+#{result[:sum]}"
      {winnings: 6, status: win_text}
    else
      {winnings: 0, status: lose_text}
    end
 end

  def update_and_display_score(dice, guess)
    update_screen(dice, guess)
    blank_screen
    puts @screen
  end

  def run
    super

    basic_guess = {
      even: %w[h han e even],
      odd: %w[c cho o odd],
      sum: %w[+2 +3 +4 +5 +6 +7 7 +8 8 +9 9 +10 10 +11 11 +12 12],
      difference: %w[0 -0 -1 -2 -3 -4 -5],
      single: %w[1 2 3 4 5 6]
    }

    blank_screen

    loop do
      guess = get_valid_answer("What is your guess? $#{@cash}".center(31), basic_guess.values.flatten)

      return puts "Thanks for playing!".centered(31) unless guess[:response]

      guess = resolve_guess(categorize_response(guess[:response], basic_guess), guess[:response])

      dice = roll_dice

      update_and_display_score(dice, guess)
    end
  end

  def resolve_guess(guess_key, guess)
    case guess_key
    when :odd
      'odd'
    when :even
      'even'
    when :single
      guess.to_i
    when :difference, :sum
      if %w[7 8 9 10 11 12].include? guess
        "+#{guess}" 
      elsif guess == "0" 
        '-0'
      else
        guess
      end
    end
  end
end
