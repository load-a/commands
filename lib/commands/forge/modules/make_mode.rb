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
    lib = resolve_path("#{self[:execution_directory]}/../#{script_name}")
    templates = "#{self[:execution_directory]}/templates/code"
    class_name = script_name.upperCamelCase
    other_files = %w[config.rb help.md]

    # Make the lib and module directories
    system "mkdir #{lib}" 
    system "mkdir #{lib}/modules"

    # Write the main file
    main = File.read("#{templates}/command_main.rb")
    main.sub!('CLASSNAME', class_name)
    main.sub!('filename', script_name) # :execution_directory in settings
    IO.write "#{lib}/main.rb", main

    # Create other files
    other_files.each do |file|
      IO.write "#{lib}/#{file}", ""
    end

    # Write the bin
    bin = resolve_path("#{lib}/../../../bin")
    executable = File.read "#{templates}/command_bin.rb"
    executable.sub!('filename', script_name) # The require line
    executable.sub!('CLASSNAME', class_name) # The class name

    IO.write "#{bin}/#{script_name}", executable
    
    system "chmod 751 #{bin}/#{script_name}"

    puts "#{class_name} Command generated!"
  end
end
