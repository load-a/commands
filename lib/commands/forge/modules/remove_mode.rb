# frozen_string_literal: true

module RemoveMode
  def remove_file(file_parameter = parameters.first)
    determine_file_settings(file_parameter)

    return puts "Cannot Remove: #{self[:filepath]} -- Does not exist." unless File.exist? self[:filepath]

    puts "Removing file: #{self[:filepath]}"
    system "rm #{self[:filepath]}"

    if self[:directory]
      puts "Removing directory: #{self[:file_dir]}"
      system "rmdir #{self[:file_dir]}"
    end
  end

  def remove_script(script_name)
    return unless confirm? "Are you sure you want to remove the #{script_name.upper_camel_case} Command?"
    lib = resolve_path("#{self[:execution_directory]}/../#{script_name}")
    bin = resolve_path("#{lib}/../../../bin")

    system "rm -r #{lib}"
    system "rm #{bin}/#{script_name}"

    puts "Removed #{script_name.upper_camel}"
  end
end
