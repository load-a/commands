# frozen_string_literal: true

module BasicFunctions
  def configure
    puts 'CONFIGURATION MODE:' 
    display_hash settings, 2 # @todo This should actually just change the config file
  end

  def help
    puts 'HELP MODE:'
    display_hash options, 2
  end

  def inspect
    indentation = 2
    puts 'INSPECTION MODE:', "RAW: #{raw}", "TOKENS:"
    display_hash tokens, indentation
    puts 'STATE:'
    display_hash state, indentation
  end

  def reset
    puts 'RESET MODE:'
    # Reset config file
  end

  def display_hash(hash, indentation = 0)
    max_key_length = hash.keys.map(&:to_s).map(&:length).max

    hash.each do |key, value|
      if value.is_a? Hash
        puts "#{' ' * indentation}#{key}: {#{value.empty? ? '' : '...'}}"
        display_hash value, indentation + 2
      else
        value = '<NIL>' if value.nil?
        puts "#{(' ' * indentation)}#{key.to_s.ljust(max_key_length)}: #{value}"
        # puts format('%s%s: %s', (' ' * indentation), key, value)
      end
    end
  end
end
