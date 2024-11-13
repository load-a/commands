module FlagHandler
  # Takes the valid flag hash from initialization and extracts every valid
  # flag from it
  # @return [Void]
  def create_options_array
    return self.options = [] if assigned_options.empty?

    self.options = []
    assigned_options.each do |verbose, simple|
      options << "--#{verbose}"
      if simple.is_a?(Array)
        simple.each { |flag| options << (flag.start_with?('-') ? flag : "-#{flag}") }
      else
        options << (simple.start_with?('-') ? simple : "-#{simple}")
      end
    end

    raise FlagAssignmentError if options.any? { |flag| HELP_OPTIONS.include? flag }

    self.options += HELP_OPTIONS
  end

  def receive_possible_flags
    # Simple flags can be 1 to 3 letters long and can optionally end with a '+'
    # Verbose flags must start with a double hyphen followed by a letter.
    #   It can thereafter have any number of letters, underscores or numbers

    received[:flags] = inputs.grep(/(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/) || []

    return if received[:flags].length >= flag_limit.min

    raise InputQuantityError.new('Flags', received[:flags], flag_limit)
  end

  def accepted_flags
    return if options.empty?

    accepted[:flags] = received[:flags].dup
    accepted[:flags].slice!(flag_limit.max..-1)

    return if flag_limit.include? accepted[:flags].length

    raise InputError, "Insufficient flags; Minimum required: #{flag_limit.min}"
  end

  def validate_flags
    accepted[:flags].each do |found_flag|
      raise InvalidFlagError.new(**flag_error_packet(found_flag)) unless options.include? found_flag
    end
  end

  def flag_error_packet(erroneous_flag)
    {
      input: erroneous_flag,
      position: inputs.index(erroneous_flag),
      acceptable: options
    }
  end
end
