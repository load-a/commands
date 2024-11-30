# frozen_string_literal: true

require_relative '../../core/command/main'

class Forge < Command
  def initialize(argv)
    self.default_options = {
        ruby: 'r'
    }

    self.default_settings = {
        case_sensitive: :parameters,
        send_directory: CALL_PATH,
        type: 'none',
    }
    super
  end

  def directory_legend
    [
        "HOME: #{HOME_PATH}",
        "CALL: #{CALL_PATH}",
        "EXEC: #{settings[:execution_directory]}",
        "SEND: #{settings[:send_directory]}",
    ]
  end

  def generate_file
    system "touch #{settings[:execution_directory]}/#{parameters}"
    puts "forged: #{settings[:execution_directory]}/#{parameters}"
  end

  def remove_file
    system "rm #{settings[:execution_directory]}/#{parameters}"
    puts "removed: #{settings[:execution_directory]}/#{parameters}"
  end

  def run
    super
    # puts directory_legend
    if check_mode(:make)
      generate_file
    end

  end
end
