# frozen_string_literal: true

require_relative '../../core/command/main'

class Forge < Command
  TEMPLATES = "#{File.dirname(__FILE__)}/templates"

  def initialize(argv = [])
    self.options = {
      make: %w[m mk new w --new --write --create],
      remove: %w[r rm d del --delete],
      copy: %w[c cp],
      rename: %w[n mv rn --name --move]
    }

    self.settings = {
      default_mode: :make,
      send_directory: Dir.pwd,
      case_sensitivity: %i[settings parameters],
      type: '',
      subtype: '',
      parameter_limit: (1..9),
      mode_limit: (0..2),
      filepath: '',
      file_dir: '',
      filename: ''
    }

    self.adjustments = {
      make: {
        overwrite: false,
        generate: false,
      },
      copy: {
        original: '',
        copies: [],
        overwrite: false,
        parameter_limit: (2..9),
        generate: true
      },
      remove: {
        check: 2,
        directory: false,
      },
      script: {
        parameter_limit: (1..1)
      },
      rename: {
        parameter_limit: (2..2)
      }
    }
    self.directives = {
      execution_directory: Dir.home + '/commands/lib/commands/forge',
      case_sensitivity: %i[settings parameters]
    }

    @extension = ''
    @contents = ''

    super
  end

  def resolve_path(path)
    File.expand_path(path.to_s)
  end

  def path_conflict?(input_file, expanded_file)
    # 1. Is the input just the base name? [if so then return; no problem]
    # 2. Is the named directory different than the send directory? [if same then no problem]
    input_file == File.basename(expanded_file) && !(File.dirname(expanded_file) == self[:send_directory])
    # @todo This and the resolution are confusing the issue. This check and the resolution have a direct relationship to the full path,
    #   but rn only the resolution is determining that.
    #   If the FILE is just a basename, then use the send_directory
    #   If the file is not, resolve the conflict manually
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

 # Generates the full path based on the input filename and template extension
 def determine_file_settings(file_parameter)
  filepath = determine_file_path(file_parameter)

  self[:filepath] = filepath
  self[:filepath] += ".#{@extension}" unless @extension.empty?

  self[:file_dir] = File.dirname(filepath)
  self[:filename] = File.basename(filepath)
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

  def generate_template(file_parameter)
    load_template(File.basename(file_parameter)) unless self[:type].empty?
  end

  def make_file(file_parameter = parameters.first, contents = nil)
    determine_file_settings(file_parameter)

    generate_directory

    return puts "Cannot overwrite file: #{self[:filepath]}" if File.exist?(self[:filepath]) && self[:overwrite] == false

    puts "Writing file: #{self[:filepath]}"
    contents = @contents if contents.nil?

    IO.write self[:filepath], contents
  end

  def generate_directory
    unless Dir.exist? self[:file_dir]
      if self[:generate]
        system "mkdir #{self[:file_dir]}"
      else
        raise "Directory does not exist" 
      end
    end
  end

  def generate_script(script_name)
    # make bin
    # make lib/commands/
    # make main, help.md and config
    # Give rwx-rx-x permissions to bin
  end

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

  def check_for_template(filename)
    if self[:type] == nil
      filename
    else
      load_template(File.base_name(filename))
      "#{filename}.#{@extension}"
    end
  end

  def load_template(file_title)
    @extension, @contents = switch_type
    load_contents(file_title)
  end

  def switch_type
    text_template = "#{TEMPLATES}/text/template"
    code_template = "#{TEMPLATES}/code/template"

    case self[:type]
    when 'text'
      ['txt', "#{text_template}.txt"]
    when 'markdown'
      ['md', "#{text_template}.md"]
    when 'c'
      ['c', "#{code_template}.c"]
    when 'cobol'
      ['cob', "#{code_template}.cob"]
    when 'cpp'
      ['cpp', "#{code_template}.cpp"]
    when 'java'
      ['java',
       (self[:subtype].downcase == 'main' ? "#{TEMPLATES}/code/main_template.java" : "#{code_template}.java")]
     when 'ruby'
      ['rb', "#{code_template}.rb"]
    when 'rust'
      ['rs', "#{code_template}.rs"]
    when 'script'
      raise "Not implemented"
    else
      raise 'Invalid Type'
    end
  end

  def load_contents(file_title)
    @contents = File.read @contents
    @contents.gsub!('THIS', file_title.capitalize)
  end

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

  def run
    super if self[:input_modes].empty?

    each_mode do |mode|
      super

      case mode
      when :make
        check_for_empty_filename

        each_parameter do |file|
          generate_template(file)
          make_file(file)
        end
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
          generate_template(file)
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
      when :rename
        if parameters.length != 2
          raise CommandErrors::InputError.new('parameters', parameters.length, self[:parameter_limit]) 
        end

        rename_file(parameters[0], parameters[1])
      end
    end
  end

  def check_for_empty_filename
    raise 'Cannot have empty file name' if parameters.first.nil?
  end
end
