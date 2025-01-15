# frozen_string_literal: true

module PermitMode
  def permit(file)
    # For each member:
    # - match pattern
    # - convert each letter into its number
    # - use the bottom three bits of said number as permission status
    # - apply status to member

    table = {
      r: 4,
      w: 2,
      x: 1
    }

    permissions = 
    puts "permitting #{file}"
  end
end
