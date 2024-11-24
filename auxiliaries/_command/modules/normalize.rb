require_relative '../class_extensions/class_extensions'

module Normalize
  module_function

  def to_array(object, flatten: false)
    return [] if object.nil?

    array = object.is_a?(Array) ? object : [object]

    case flatten
    when true
      array.flatten
    when Integer
      array.flatten(flatten)
    else
      array
    end
  end

  def from_array(array)
    raise "Must pass in an Array" unless array.is_a?(Array)
    array.length == 1 ? array.first : array
  end

  def from_string(string, numeric_default: 0)
    if string.numeric?
      string.to_numeric(numeric_default)
    elsif %w[true false].include?(string.downcase)
      (string == 'true')
    elsif string.start_with?(':')
      string[1..].to_sym
    elsif string.start_with?('[') && string.end_with?(']')
      array = parse_array_string(string)
      raise "CONVERSION ERROR: #{array[1]}/#{string.length}" if array[1] + 1 != string.length
      array[0]
    else
      string
    end
  end

  def parse_array_string(string, index = 0)
    result = []
    index += 1
    word = ''
    escaped = false

    while index <= string.length
      current_char = string[index]

      case current_char
      when ']'
        if escaped
          word << current_char
          escaped = false
        else
          result << from_string(word.strip) unless word.empty?
          return [result, index]
        end
      when '['
        nested_array, index = parse_array_string(string, index)
        result << nested_array
        word = ''
      when ','
        result << from_string(word.strip) unless word.empty?
        word = ''
      else
        escaped = true if current_char =~ /\\/
        word << current_char
      end

      index += 1
    end

    raise "PARSE ERROR #{index}/#{string.length}"
  end
end
