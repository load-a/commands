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
end
