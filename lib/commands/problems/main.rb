# frozen_string_literal: true

require_relative '../../core/command/main'

class Problems < Command
  OPERATIONS = {
    addition: '+',
    subtraction: '-',
    multiplication: '*',
    division: '/',
    modulo: '%'
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
      digits: 1, # The primary number of digits
      operator_digits: 0, # The number of digits the operator has; if left at zero it will match :digits
      questions: 10, # The number of problems to generate
      answers: true, # Whether answers are included with the questions
      negative: 0, # the percentage of randomly generated negative operands. 
    }

    self.adjustments = {
      addition: {}, 
      subtraction: {},
      multiplication: {},
      division: {
        modulo: false, # division returns only the remainder (normally it returns the quotient and remainder by default)
        float: false # Whether divisions return floating point numbers
      },
      mixed: {}
    }

    self.directives = {
      case_sensitivity: [:settings],
    }

    super
  end

  # Generates a math problem using the configured settings.
  # @return [String]
  def generate_problem
    operand = number_in_range(self[:digits])
    operator = number_in_range(self[:operator_digits])
    operation = OPERATIONS[self[:active_mode]]

    # Returns a blank space if the number is not negative.
    # @param number [Numeric]
    # @return [String]
    def spaced(number)
      number.negative? ? '' : ' '
    end

    # Creates a string containing the number and a leading empty space if it is not negative.
    # @param number [Numeric]
    # @return [String]
    def formatted(number)
      "#{spaced(number)}#{number}"
    end

    problem = "#{formatted(operand)} #{operation} #{formatted(operator)} "
    
    return problem unless self[:answers]

    # An auxiliary method for the result.
    # It generates a formatted string containing the remainder of a division unless the :float setting is set.
    # @param dividend [Numeric] The number being divided
    # @param divisor [Numeric] The number doing the division
    def remainder(dividend, divisor)
      return if self[:float] == true

      "r#{dividend % divisor}"
    end

    result = operand.send(operation, operator)
    result_string = "= #{formatted(result)} #{remainder(operand, operator) if operation == '/'}"

    problem + result_string
  end



  # Generates a number within the given number of digits. 
  # It generates random numbers between the lowest and highest possible values with that number of digits.
  # (i.e. for 4 digits it will choose between 1000 and 9999).
  # If the :float setting is set, the number returned will be a Float.
  # It has :negative setting percent chance of generating a negative number.
  # (i.e. :negative = 10, 10% chance the number is negative.)
  # It will never generate a zero.
  # @param digits [Integer]
  # @return [Integer, Float]
  def number_in_range(digits)
    digits = 1 unless digits.is_a? Integer
    digits = 1 if digits < 1

    low = (10 ** (digits - 1))
    high = ((10 ** digits) - 1)

    number = rand(low..high)

    number = -number if rand(1..100) <= Normalize.from_string(self[:negative])

    number = number.to_f if self[:float]

    number
  end

  # Generates a number of math problems. 
  # If :send_directory is an extant file, it will write the questions to that file after confirming with the user.
  # Otherwise, it will print the questions to the screen.
  def run
    output = []

    sending = File.exist?(self[:send_directory].to_s)

    if self[:operator_digits].zero?
      self[:operator_digits] = self[:digits]
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
      self[:active_mode] = OPERATIONS.keys[0...-1].sample if mode == :mixed
      self[:active_mode] = :modulo if self[:active_mode] == :division && self[:modulo]

      if sending
        output << generate_problem
      else
        puts generate_problem
      end
    end

    if sending
      return unless confirm? "Are you sure you want to overwrite #{self[:send_directory]}?"
      IO.write self[:send_directory], output.join("\n") 
      puts "Sending examples to #{self[:send_directory]}"
    end
  end
end
