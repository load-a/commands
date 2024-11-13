# frozen_string_literal: true

# @todo This actually makes for a good error message.
#   Try to get this to show up either as part of the help message or some kind of error

class Inspector
  attr_accessor :parent

  def initialize(parent)
    self.parent = parent
    run
  end

  private def method_missing(name, *args)
    parent.send(name, *args)
  end

  def repond_to_missing?
    true
  end

  def run
    puts "INSPECTION ON #{parent}", 'INPUTS:', "\t#{inputs}"
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
      "\tExec: #{execution_path}"
    ]
  end

  def check_keywords
    fraction = assigned_keywords.keys.count { |expected_key| uses_keyword? expected_key }
    fulfilled = case assigned_keywords.size - fraction
                when 0 then 'Yes'
                when assigned_keywords.size then 'No'
                else 'Some'
                end

    ['KEYWORDS:', "\tExpected: {",
     assigned_keywords.map { |assignment, explanation| "\t  #{assignment} -> #{explanation}" }.join("\n"),
     "\t}",
     "\tReceived: #{received[:keywords]}", "\tAccepted: #{keywords}",
     "\tFulfilled: #{fulfilled} (#{fraction}/#{assigned_keywords.size})"]
  end
end
