# frozen_string_literal: true

module FileManager
  def resolve_path(path)
    File.expand_path(path.to_s)
  end

  def path_conflict?(input_file, expanded_file)
    if File.identical?(input_file, expanded_file)
      # If the input file is the same as the inferred file there is no conflict
      false
    elsif File.dirname(expanded_file) == self[:send_directory]
      # If the expanded path directory matches the current send directory then there is no conflict
      false
    elsif File.dirname(input_file).nil?
      false
    else
      true
    end
    # 1. Is the input just the base name? [if so then return; no problem]
    # 2. Is the named directory different than the send directory? [if same then no problem]

    # @todo This and the resolution are confusing the issue. This check and the resolution have a direct relationship to the full path,
    #   but rn only the resolution is determining that.
    #   If the FILE is just a basename, then use the send_directory
    #   If the file is not, resolve the conflict manually
  end

  def resolve_conflict(input_file, expanded_file)
    inffered_directory = File.dirname(expanded_file)
    given_directory = resolve_path "#{self[:send_directory]}/#{File.dirname(input_file)}"
    conflict_prompt = [
      "Forge encountered a path conflict:",
      "The Inferred Directory is: #{inffered_directory}",
      "   the Given Directory is: #{given_directory}",
    ].join("\n")

    puts conflict_prompt

    return self[:send_directory] = inffered_directory if confirm?("Use the Inferred Path? (y/n): #{expanded_file}")

    given_path = resolve_path "#{self[:send_directory]}/#{input_file}"

    return if confirm? "Use the Given Path? (y/n): #{given_path}"

    raise "Unresolved Path Conflict"
  end

  def determine_file_path(filename)
    expanded_path = resolve_path(filename)

    if self[:send_directory] != Dir.pwd 
      resolve_conflict(filename, expanded_path) unless File.dirname(filename) == '.'
      resolve_path "#{self[:send_directory]}/#{filename}"  
    else
      expanded_path
    end
  end
end
