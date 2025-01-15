# frozen_string_literal: true

module MakeMode
  def make_file(file_parameter = parameters.first, contents = nil)
    determine_file_settings(file_parameter)

    generate_directory

    return puts "Cannot overwrite file: #{self[:filepath]}" if File.exist?(self[:filepath]) && self[:overwrite] == false

    puts "Writing file: #{self[:filepath]}"
    contents = @contents if contents.nil?

    IO.write self[:filepath], contents
  end

  def generate_directory
    unless Dir.exist? self[:file_dir]
      if self[:generate]
        system "mkdir #{self[:file_dir]}"
      else
        raise "Directory does not exist" 
      end
    end
  end

  def generate_script(script_name)
    # make bin
    # make lib/commands/
    # make main, help.md and config
    # Give rwx-rx-x permissions to bin
  end
end
