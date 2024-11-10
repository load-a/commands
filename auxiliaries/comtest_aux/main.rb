# frozen_string_literal: true

require_relative '../_command/command'

# @todo This actually makes for a good error message.
#   Try to get this to show up either as part of the help message or some kind of error

class Comtest < Command
  def initialize(_argv, flag_limit: (0..1), parameter_limit: (0..2), case_sensitive: :keywords)
    self.option_assignments = {
      test_flag_one: 'flg',
      test_flag_two: 'tf+'
    }

    self.keyword_assignments = {
      int: 'Some kind of Integer',
      string: 'Some kind of String'
    }

    super
  end

  def run
    super
    puts 'INPUTS:', "\t#{inputs}"
    puts check_flags
    puts check_args
    puts check_keywords
    puts check_paths
    puts 'OTHER:', "\tCase Sensitivity: #{case_sensitivity}"
  end

  def check_flags
    [
      'FLAGS:',
      "\tReceived: #{received[:flags]}",
      "\tAccepted: #{flags}",
      "\tOptions: #{options}",
      "\tLimit: #{flag_limit}"
    ]
  end

  def check_args
    [
      'PARAMETERS:',
      "\tReceived: #{received[:parameters]}",
      "\tAccepted: #{parameters}",
      "\tNumber of Arguments?: #{parameters.is_a?(String) ? 1 : parameters.size}",
      "\tLimit: #{parameter_limit}"
    ]
  end

  def check_paths
    [
      'PATHS:',
      "\tCall: #{CALL_PATH}",
      "\tHome: #{HOME_PATH}",
      "\tMain: #{MAIN_PATH}",
      "\tAux.: #{AUXILIARIES_PATH}",
      "\tExec: #{@execution_path}"
    ]
  end

  def check_keywords
    fraction = keyword_assignments.keys.count { |expected_key| keywords.keys.include? expected_key }
    fulfilled = case keyword_assignments.size - fraction
                when 0 then 'Yes'
                when keyword_assignments.size then 'No'
                else 'Some'
                end

    ['KEYWORDS:', "\tExpected:",
     keyword_assignments.map { |assignment, explanation| "\t* #{assignment}: #{explanation}" }.join("\n"),
     "\tReceived: #{received_keywords}", "\tAccepted: #{keywords}",
     "\tFulfilled: #{fulfilled} (#{fraction}/#{keyword_assignments.size})"]
  end
end
