# frozen_string_literal: true

require_relative '../../core/command/main'

class Forge < Command
  TEMPLATES = "#{File.dirname(__FILE__)}/templates"

  def initialize(argv = [])
    self.options = {
      make: %w[m mk],
      remove: %w[r rm],
      copy: %w[c cp],
      script: %w[s scr]
    }

    self.settings = {
      default_mode: :make,
      send_directory: Dir.pwd,
      case_sensitivity: %i[settings parameters],
      type: nil,
      subtype: nil,
      parameter_limit: (1..9),
      mode_limit: (0..2)
    }

    self.adjustments = {
      make: {
        overwrite: false,
        generate: false
      },
      copy: {
        original: nil,
        copies: [],
        overwrite: false,
        parameter_limit: (2..9),
        generate: true
      },
      remove: {
        check: 2,
        directory: false
      },
      script: {
        parameter_limit: (1..1)
      }
    }
    self.directives = {
      execution_directory: Dir.home + '/commands/lib/commands/forge',
      case_sensitivity: %i[settings parameters],
      type: state&.dig(:settings, :type)&.to_sym,
      subtype: state&.dig(:settings, :subtype)&.to_sym
    }

    @extension = ''
    @contents = ''

    super
  end

  def enforce_directives
    directives.each do |key, value|
      state[:settings][key] = value
    end
  end



  def resolve_path(path)
    File.expand_path(path)
  end

  def path_conflict?(input_file, expanded_file)
    # 1. Is the input just the base name? [if so then return; no problem]
    # 2. Is the named directory different than the send directory? [if same then no problem]
    input_file == File.basename(expanded_file) && !(File.dirname(expanded_file) == self[:send_directory])
  end

  def resolve_conflict(input_file, expanded_file)
    inffered_directory = File.dirname(expanded_file)
    send_directory = self[:send_directory]

    inferred_prompt = [
      "Forge encountered a path conflict:",
      "The Inferred Directory is: #{inffered_directory}",
      "but the Send Directory is: #{send_directory}",
      "Use the inferred path: #{expanded_file}? (y/n)"
    ]

    use_inferred = confirm? inferred_prompt.join("\n")

    return self[:send_directory] = inffered_directory if use_inferred

    return if confirm? "Use :send_directory #{send_directory}/#{input_file}?"

    raise CommandErrors::CommandError.new "Unresolved Path Conflict"
  end

  def determine_file_path(filename)
    expanded_path = resolve_path(filename)

    if path_conflict?(filename, expanded_path)
     resolve_conflict(filename, expanded_path) 
     "#{self[:send_directory]}/#{filename}"
   else
     expanded_path
   end
 end

 def generate_file_path_and_contents(file_parameter)
  get_template(File.basename(file_parameter)) if self[:type]

  filename = determine_file_path(file_parameter)
  filename = "#{filename}.#{@extension}" unless @extension.empty?
  filename
 end

  # Steps to make a file
  # - Figure out the path
  #   * Use File.expand_path to have Ruby determine the absolute path by default
  #   * Ignore the :send_directory unless used (how? maybe compare the two? maybe ask if there's ambiguity?)
  #   * Document intended behavior!
  # - Figure out if it uses a template
  #   * Determined entirely by the presence of a :type
  #   * Warn "No template found" and proceed as normal on failure
  # - Figure out if the directory exists or should be created
  #   * 
  # - Figure out if the file exists or should be overwritten
  # - Make the file
  # - Grant necessary permissions

  def make_file(file_parameter = parameters.first, contents = nil)
    filepath = generate_file_path_and_contents(file_parameter)
    file_dir = File.dirname(filepath)

    unless Dir.exist? file_dir
      if self[:generate]
        system "mkdir #{file_dir}"
      else
        raise "Directory does not exist" 
      end
    end

    return puts "Cannot overwrite file: #{filepath}" if File.exist?(filepath) && self[:overwrite] == false

    puts "Writing file: #{filepath}"
    contents = @contents if contents.nil?

    IO.write filepath, contents
  end

  def remove_file(file_parameter = parameters.first)
    filepath = generate_file_path_and_contents(file_parameter)
    file_dir = File.dirname(filepath)

    return puts "Cannot Remove: #{filepath} -- Does not exist." unless File.exist? filepath

    puts "Removing file: #{filepath}"
    system "rm #{filepath}"

    if self[:directory]
      puts "Removing directory: #{file_dir}"
      system "rmdir #{file_dir}"
    end
  end

  def check_for_template(filename)
    if self[:type] == nil
      filename
    else
      get_template(File.base_name(filename))
      "#{filename}.#{@extension}"
    end
  end

  def get_template(file_title)
    @extension, @contents = switch_type
    get_contents(file_title)
  end

  def switch_type
    text_template = "#{TEMPLATES}/text/template"
    code_template = "#{TEMPLATES}/code/template"

    case self[:type].to_sym
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
       (self[:subtype].downcase == 'main' ? "#{TEMPLATES}/code/main_template.java" : "#{code_template}.java")]
     when :ruby
      ['rb', "#{code_template}.rb"]
    when :rust
      ['rs', "#{code_template}.rs"]
    else
      raise 'Invalid Type'
    end
  end

  def get_contents(file_title)
    @contents = File.read @contents
    @contents.gsub!('THIS', file_title.capitalize)
  end

  def copy_file(original, copy)
    original = generate_file_path_and_contents(original)
    copy = generate_file_path_and_contents(copy)

    return puts "Cannot copy #{original} -- File does not exist" unless File.exist?(original)
    return puts "Cannot generate #{copy} -- File does not exist or Setting is false" unless File.exist?(copy) || self[:generate]
    return puts "Cannot overwrite #{copy} -- Setting is false" if File.exist?(copy) && self[:overwrite] == false

    # Might be necessary; Implemented this way because the protections in make_file might be utilized when making copies
    # More investigation needed
    @contents = File.read original
    make_file(copy, @contents)
    
    puts "Copying #{original} -> #{copy}"
  end

  def run
    super if self[:input_modes].empty?

    each_mode do |mode|
      super

      case mode
      when :make
        check_for_empty_filename
        each_parameter(:make_file)
      when :remove
        check_for_empty_filename
        files_to_remove = parameters.length

        if files_to_remove >= self[:check] 
          confirm_prompt = [
            "Are you sure you want to remove #{files_to_remove} files?",
            parameters.join("\n")
          ]
          return unless confirm?(confirm_prompt.join("\n"))
        end

        each_parameter do |file|
          remove_file(file)
        end
      when :copy
        check_for_empty_filename
        check_for_parameters(2)

        self[:original] = parameters.first
        self[:copies] = parameters[1..]
        
        self[:copies].each do |copy|
          copy_file(self[:original], copy)
        end
      when :script

      end
    end
  end

  def check_for_empty_filename
    raise 'Cannot have empty file name' if parameters.first.nil?
  end
end
