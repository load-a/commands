# frozen_string_literal: true

# Provides a convenient and safe way to handle creating, deleting and overwriting files.
module Filer
  def write_file(path:, content:)
    return if File.exist?(path) && !(confirm? "The file '#{path}' already exists. Do you want to overwrite it?")

    File.write(path, content)
  end

  alias create_file write_file

  def give_permissions(file_name, mode: 0o751)
    mode = mode_from_string(mode).to_i(8) if mode.is_a? String

    File.chmod mode, file_name
  end

  # @return [String]
  def mode_from_string(mode)
    raise 'Incorrect mode format.' unless mode =~ /^([rwx-]{3}){3}$/

    mode.scan(/.{3}/).map do |entity|
      int = 0
      int += 4 if entity.include? 'r'
      int += 2 if entity.include? 'w'
      int += 1 if entity.include? 'x'
      int.to_s(8)
    end.join.rjust(3, '0')
  end
end
