# frozen_string_literal: true

require_relative '../../core/command/main'

DirReq.require_directory File.dirname(__FILE__) + '/modules'

class CLASSNAME < Command
  def initialize(argv = [])
      self.options = {}

      self.settings = {
        default_mode: :bypass,
        send_directory: Dir.pwd,
        case_sensitivity: %i[settings parameters],
        parameter_limit: (1..9),
        mode_limit: (0..2),
      }

      self.adjustments = {}

      self.directives = {
        execution_directory: File.dirname(__FILE__),
        case_sensitivity: %i[settings parameters]
      }

      super
    end

  def run
    super
    # Add code here
  end
end
