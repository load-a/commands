# frozen_string_literal: true

require_relative '../../core/command/main'

class Forge < Command
  TEMPLATES = "#{File.dirname(__FILE__)}/templates"

  def initialize(argv = [])
    self.options = {
      make: %w[m mk],
      remove: %w[r rm],
      copy: %w[c cp],
    }

    self.settings = {
      default_mode: :make,
      send_directory: Dir.pwd,
      case_sensitivity: %i[settings parameters],
      type: :empty,
      subtype: :empty,
      parameter_limit: (1..9)
    }

    self.adjustments = {
      make: {
        overwrite: false
      },
      copy: {
        overwrite: false
      },
      remove: {},
    }

    @extension = ''
    @contents = ''

    super
  end

  def enforce_default_settings
    default_configs = {
      execution_directory: Dir.home + '/commands/lib/commands/forge',
      case_sensitivity: %i[settings parameters],
      type: state[:settings][:type].to_sym,
      subtype: state[:settings][:subtype].to_sym
    }

    default_configs.each do |key, value|
      state[:settings][key] = value
    end
  end

  def make_file(file_title = parameters.first)
    file_name = "#{self[:send_directory]}/#{file_title}"

    file_name = check_for_template(file_name)

    return puts "Cannot overwrite file: #{file_name}" if File.exist?(file_name) && self[:overwrite] == false

    puts "Creating file: #{file_name}"
    IO.write file_name, @contents
  end

  def remove_file(file_title = parameters.first)
    file_name = "#{self[:send_directory]}/#{file_title}"

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
      each_parameter(:make_file)
    when :remove
      each_parameter do |file|
        remove_file(file)
      end
    end
  end
end
