# frozen_string_literal: true

module CopyMode
  def copy_file(original, copy)
    determine_file_settings(original)
    original = self[:filepath]

    determine_file_settings(copy)
    copy = self[:filepath]

    return puts "Cannot copy #{original} -- File does not exist" unless File.exist?(original)
    return puts "Cannot generate #{copy} -- File does not exist or Setting is false" unless File.exist?(copy) || self[:generate]
    return puts "Cannot overwrite #{copy} -- Setting is false" if File.exist?(copy) && self[:overwrite] == false

    IO.write copy, File.read(original)
    puts "Copying #{original} -> #{copy}"
  end
end
