# frozen_string_literal: true

require 'dir_req'

# Require needed directories (like normal)
[
  '/commands/lib/core/command/modules',
  '/commands/lib/core/command/errors',
  '/commands/lib/core/extensions'
].each do |path|
  DirReq.require_directory Dir.home + path
end

class Command
  include InputHandler
  include ModeHandler
  include SettingsHandler
  include AdjustmentHandler
  include ParameterHandler
  include FileManager

  include BasicFunctions
  include StateShortcuts
  include Prompter
  include CommandErrors

  # COMMAND_CORE_DIRECTORY = File.dirname(__FILE__)
  
  attr_accessor :raw, :tokens, :state,
  :options, :settings, :adjustments, :directives

  def initialize(argv = [])
    set_default_attributes

    update_from_input argv

    # @todo Shift all core modes to the end. Then whatever comes first is the true mode. Do each core mode and pop it off
    #   the :modes array until the last one remains. Then run that last one.
  end

  def set_default_attributes
    generate_options
    generate_settings
    generate_adjustments
    reset_state
  end

  def reset_state
    self.state = {
      modes: [],
      settings: settings,
      parameters: []
    }
  end

  def enforce_directives
    return unless directives
    directives.each do |key, value|
      state[:settings][key] = value
    end
  end

  def check_for_parameters(number)
    parameters_found = parameters.length
    parameters_needed = state[:settings][:parameter_limit]

    unless parameters_needed.include? parameters_found
      raise CommandErrors::InputError.new('Parameters', parameters_found, parameters_needed) 
    end
  end

  def run
    self[:core_modes].each do |mode|
      send(mode)
    end
  end

  def bypass; end
end
