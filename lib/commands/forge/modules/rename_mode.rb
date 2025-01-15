# frozen_string_literal: true

module RenameMode
  def rename_file(original, new_name)
    determine_file_settings(original)
    old_name = self[:filepath]

    determine_file_settings(new_name)
    new_name = self[:filepath]

    if confirm? "Rename: #{old_name} -> #{new_name}? (y/n)"
      system "mv #{old_name} #{new_name}"
    else
      exit 1
    end
  end
end
