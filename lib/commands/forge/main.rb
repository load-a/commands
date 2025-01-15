# frozen_string_literal: true

require_relative '../../core/command/main'

DirReq.require_directory File.dirname(__FILE__) + '/modules'

class Forge < Command
  include MakeMode
  include RemoveMode
  include CopyMode
  include RenameMode
  include PermitMode

  TEMPLATES = "#{File.dirname(__FILE__)}/templates"

  def initialize(argv = [])
    self.options = {
      make: %w[m mk new w --new --write --create],
      remove: %w[r rm d del --delete],
      copy: %w[c cp],
      rename: %w[n mv rn --name --move],
      permit: %w[p --perm],
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
        check: 3,
        directory: false,
      },
      script: {
        parameter_limit: (1..1)
      },
      rename: {
        parameter_limit: (2..2)
      },
      permit: {
        permissions: 'rwx-rx-x'
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
      ['rb', 
        self[:subtype] == 'module' ? "#{TEMPLATES}/code/module_template.rb" :  "#{code_template}.rb"]
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
      when :permit
        each_parameter(:permit)
        puts "permissions are #{Normalize.from_string self[:permissions]}"
      end
    end
  end

  def check_for_empty_filename
    raise 'Cannot have empty file name' if parameters.first.nil?
  end
end
