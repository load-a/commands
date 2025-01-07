# frozen_string_literal: true

require_relative '../../core/command/main'

class Problems < Command
  OPERATIONS = {
    addition: '+',
    subtraction: '-',
    multiplication: '*',
    division: '/'
  }

  def initialize(argv)
    self.options = {
      addition: %w[a add --add --plus],
      subtraction: %w[s sub --sub --minus --from],
      division: %w[d div --div by --by],
      multiplication: %w[m mul --mul --mult --times -for --for],
      mixed: %w[mix all]
    }

    self.settings = {
      default_mode: :addition,
      digits: 1,
      lower_digits: 0,
      questions: 10,
      answers: true,
      negatives: false,
    }

    self.adjustments = {
      addition: {}, 
      subtraction: {},
      multiplication: {},
      division: {
        modulo: false,
        float: false
      }
    }

    self.directives = {
      case_sensitivity: [false],
    }

    super
  end

  def generate_problem
    operand1 = number_in_range(self[:digits])
    operand2 = number_in_range(self[:lower_digits])
    operation = OPERATIONS[self[:active_mode]]

    puts "#{operand1} #{operation} #{operand2} = #{operand1.send operation, operand2}"
  end

  def number_in_range(digits)
    digits = 1 unless digits.is_a? Integer
    digits = 1 if digits < 1

    low = (10 ** (digits - 1))
    high = ((10 ** digits) - 1)

    rand(low..high)
  end

  def run
    if self[:lower_digits].zero?
      self[:lower_digits] = self[:digits]
    end

    self[:active_mode] = if self[:input_modes].empty?
                           self[:default_mode]
                         else
                           self[:input_modes].first
                         end

    super

    questions = if Normalize.from_string(parameters.first).is_a? Integer
                  parameters.first.to_i
                else
                  1
                end

    questions.times do 
      generate_problem
    end
  end
end
