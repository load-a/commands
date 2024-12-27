# frozen_string_literal: true

require 'dir_req'

# Require needed directories (like normal)
DirReq.require_directory Dir.home + '/commands/lib/core/command/modules'
DirReq.require_directory Dir.home + '/commands/lib/core/command/errors'
DirReq.require_directory Dir.home + '/commands/lib/core/extensions'

class Command
  include InputHandler
  include ModeHandler
  include SettingsHandler
  include AdjustmentHandler
  include ParameterHandler

  include BasicFunctions
  include StateShortcuts
  include Prompter
  
  attr_accessor :raw, :tokens, :state,
  :options, :settings, :adjustments

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

  def check_for_parameters(number)
    raise "NOT ENOUGH PARAMETERS" unless state[:settings][:parameter_limit].include? parameters.length
  end

  def run
    self[:core_modes].each do |mode|
      send(mode)
    end
  end
end
