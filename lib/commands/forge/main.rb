# frozen_string_literal: true

require_relative '../../core/command/main'

class Forge < Command
  TEMPLATES = "#{File.dirname(__FILE__)}/templates"

  def initialize(argv = [])
    self.options = {
      make: %w[m mk],
      remove: %w[r rm]
    }

    self.configurations = {
      send_directory: Dir.pwd,
      case_sensitivity: %i[configurations parameters],
      type: :empty,
      subtype: :empty,
      parameter_limit: (1..1)
    }

    @extension = ''
    @contents = ''

    super
  end

  def enforce_defaults
    default_configs = {
      execution_directory: Dir.home + '/commands/lib/commands/forge',
      case_sensitivity: %i[configurations parameters],
      type: state[:configurations][:type].to_sym,
      subtype: state[:configurations][:subtype].to_sym
    }

    default_configs.each do |key, value|
      state[:configurations][key] = value
    end
  end

  def generate_file(file_name = "#{self[:send_directory]}/#{parameters.first}")
    file_name = check_for_template(file_name)

    puts "Creating file: #{file_name}"
    IO.write file_name, @contents
  end

  def remove_file(file_name = "#{self[:send_directory]}/#{parameters.first}")
    file_name = check_for_template(file_name)

    return puts "Cannot Remove: #{file_name} -- Does not exist." unless File.exist? file_name

    puts "Removing file: #{file_name}"
    system "rm #{file_name}"
  end

  def check_for_template(file_name)
    if self[:type] == :empty
      file_name
    else
      get_template
      "#{file_name}.#{@extension}"
    end
  end

  def get_template
    text_template = "#{TEMPLATES}/text/template"
    code_template = "#{TEMPLATES}/code/template"

    @extension, @contents = case self[:type]
                            when :text
                              ['txt', "#{text_template}.txt"]
                            when :markdown
                              ['md', "#{text_template}.md"]
                            when :c
                              ['c', "#{code_template}.c"]
                            when :cobol
                              ['cob', "#{code_template}.cob"]
                            when :cpp
                              ['cpp', "#{code_template}.cpp"]
                            when :java
                              ['java',
                               (self[:subtype] == :main ? "#{TEMPLATES}/code/main_template.java" : "#{code_template}.java")]
                            when :ruby
                              ['rb', "#{code_template}.rb"]
                            when :rust
                              ['rs', "#{code_template}.rs"]
                            # when :gameboy
                            #   ['asm', "#{TEMPLATES}/code/gb_template.asm"]
                            else
                              raise 'Invalid Type'
                            end
    get_contents
  end

  def get_contents
    @contents = File.read @contents
    @contents.gsub!('THIS', parameters.first.capitalize)
  end

  def run
    super

    raise 'Cannot have empty file name' if parameters.first.nil? # @todo Put this into an actual parameter error check

    case mode
    when :make
      generate_file
    when :remove
      remove_file
    end
  end
end
