# frozen_string_literal: true

require_relative '../_command/command'
require_relative 'command_generator'

class Mint < Command
  include CommandGenerator

  def initialize(argv, flag_limit: (1..1), parameter_limit: (1..1), case_sensitive: true)
    self.mode_list = {
      bash: 'b',
      c: 'c',
      command: 'c+',
      c_plus_plus: 'cpp',
      java: %w[j j+],
      lua: 'l',
      ruby: 'r',
      rust: 'rs',
      script: %w[s+ scr],
      text: 't',
      zsh: 'z',
      remove: '-rm'
    }

    super
  end

  def run
    super
    check_for_script_flags

    file_path = determine_file_path parameters

    create_file(**generate_path_and_contents(file_path))
  end

  # Checks if an explicit path was given and adjusts @argument with the actual file name if so.
  # Otherwise it creates the path starting from the directory from which the user called this command.
  def determine_file_path(name)
    if name.include? '/'
      self.parameters = name.split('/').last
      name
    else
      "#{CALL_PATH}/#{name}"
    end
  end

  def remove_script
    script = "#{MAIN_PATH}/#{parameters}"
    script_aux = "#{AUXILIARIES_PATH}/#{parameters}_aux"
    raise InputError, "Script and Auxiliary folder don't exist. #{script_aux}" unless scripts_exist?(script, script_aux)

    `rm "#{script}"`
    `rm -r "#{script_aux}"`
  end

  def scripts_exist?(script, script_aux)
    raise InputError, "Script does not exist: #{script}" unless File.exist?(script)
    raise InputError, "Directory does not exist: #{script_aux}" unless Dir.exist?(script_aux)

    true
  end

  def check_for_script_flags
    if %w[-scr -s+ --script].include? flags
      raise InputError, 'Command Name cannot contain a space.' if parameters.include? ' '

      generate_script(parameters)
    elsif %w[-rm --remove].include? flags
      remove_script
    end
    exit
  end

  def generate_path_and_contents(file_path)
    file_creation_lookup = {
      bash: ['.sh', '#!/usr/bin/env bash'],
      c: ['.c', File.read('templates/c_template.c')],
      cpp: ['.cpp', File.read('templates/cpp_template.cpp')],
      java: ['.java', File.read('templates/java_main_template.java').gsub('THIS', parameters.capitalize)],
      java_plus: ['.java', File.read('templates/java_template.java').gsub('THIS', parameters.capitalize)],
      # lua: ['.lua', File.read('templates/lua_template.lua')],
      ruby: ['.rb', File.read('templates/ruby_template.rb')],
      rust: ['.rs', File.read('templates/rust_template.rs')],
      text: ['.txt', String.new],
      zsh: ['.sh', '#!/usr/bin/env zsh']
    }.freeze

    key = case flags
          when '-b', '--bash'
            :bash
          when '-c', '--c'
            :c
          when '-cpp', '--c_plus_plus'
            :cpp
          when '-j', '--java'
            :java
          when '-j+'
            :java_plus
          when '-l', '--lua'
            :lua
          when '-r', '--ruby'
            :ruby
          when '-rs', '--rust'
            :rust
          when '-t', '--text'
            :text
          when '-z', '--zsh'
            :zsh
          else
            raise InputError, "An accepted flag has not been accounted for: #{flags}"
          end

    {
      path: file_path + file_creation_lookup[key][0],
      content: file_creation_lookup[key][1]
    }
  end
end
