# frozen_string_literal: true

module CommandGenerator
  # @todo I don't like that this is hardcoded but I need to move on.
  TEMPLATE_PATH = "#{AUXILIARIES_PATH}/mint_aux/templates/command_templates"

  # @todo the capitalization is all messed up. certain paths are redundant. need a way to remove scripts
  def generate_script(name)
    aux_name = "#{name}_aux"

    create_script_file(aux_name, name)
    create_aux_folder(aux_name)
    create_definition_file(name, aux_name)
    create_help_file(aux_name)
    # Give permissions
  end

  def create_script_file(aux_name, name)
    file_name = "#{HOME_PATH}/commands/#{name}"
    File.write(file_name,
               File.read("#{TEMPLATE_PATH}/command_template.rb").sub(
                 'THIS', aux_name
               ).sub('THIS', name.capitalize))
    give_permissions file_name
  end

  def create_aux_folder(aux_name)
    `mkdir #{AUXILIARIES_PATH}/#{aux_name}`
  end

  def create_definition_file(name, aux_name)
    File.write("#{AUXILIARIES_PATH}/#{aux_name}/main.rb",
               File.read("#{TEMPLATE_PATH}/definition_template.rb").sub(
                 'THIS', name.capitalize
               ))
  end

  def create_help_file(aux_name)
    `touch #{AUXILIARIES_PATH}/#{aux_name}/help.md`
  end
end
