require 'fileutils'

STRUCTURE_MAP = {
  # /bin
  'mint' => 'bin/mint',
  'wurdle' => 'bin/wurdle',
  'vault' => 'bin/vault',
  # /lib or other
  'outest' => 'lib/core/deprecated/outest',
  # from _command
  'auxiliaries/_command/command.rb' => 'lib/core/command/main.rb',
  'auxiliaries/_command/command_errors.rb' => 'lib/core/command/errors/errors.rb',
  'auxiliaries/_command/class_extensions/class_extensions.rb' => 'lib/core/extensions/_all.rb',
  'auxiliaries/_command/class_extensions/numeric.rb' => 'lib/core/extensions/numeric.rb',
  'auxiliaries/_command/class_extensions/string.rb' => 'lib/core/extensions/string.rb',
  'auxiliaries/_command/class_extensions/object.rb' => 'lib/core/extensions/object.rb',
  'auxiliaries/_command/inspector_aux/help.md' => 'lib/core/deprecated/inspector/help.md',
  'auxiliaries/_command/inspector_aux/main.rb' => 'lib/core/deprecated/inspector/main.rb',
  'auxiliaries/_command/modules/command_modules.rb' => 'lib/core/command/modules/_all.rb',
  'auxiliaries/_command/modules/filer.rb' => 'lib/core/command/deprecated/filer.rb',
  'auxiliaries/_command/modules/mode_handler.rb' => 'lib/core/command/modules/mode_handler.rb',
  'auxiliaries/_command/modules/normalize.rb' => 'lib/core/command/modules/normalize.rb',
  'auxiliaries/_command/modules/parameter_handler.rb' => 'lib/core/command/modules/parameter_handler.rb',
  'auxiliaries/_command/modules/prompter.rb' => 'lib/core/command/deprecated/prompter.rb',
  'auxiliaries/_command/modules/settings_handler.rb' => 'lib/core/command/modules/settings_handler.rb',
  # auxiliaries - mint
  'auxiliaries/mint_aux/templates/c_template.c' => 'lib/core/commands/mint/templates/programming/template.c',
  'auxiliaries/mint_aux/templates/cpp_template.cpp' => 'lib/core/commands/mint/templates/programming/template.cpp',
  'auxiliaries/mint_aux/templates/java_main_template.java' => 'lib/core/commands/mint/templates/programming/main_template.java',
  'auxiliaries/mint_aux/templates/java_template.java' => 'lib/core/commands/mint/templates/programming/template.java',
  'auxiliaries/mint_aux/templates/ruby_template.rb' => 'lib/core/commands/mint/templates/programming/template.rb',
  'auxiliaries/mint_aux/templates/rust_template.rs' => 'lib/core/commands/mint/templates/programming/template.rs',
  'auxiliaries/mint_aux/templates/text_template.txt' => 'lib/core/commands/mint/templates/text/template.txt',
  'auxiliaries/mint_aux/templates/constants.rb' => 'lib/core/deprecated/mint_template_constants.rb',
  'auxiliaries/mint_aux/templates/help.md' => 'lib/core/commands/mint/templates/text/help_template.md',
  'auxiliaries/mint_aux/templates/command_templates/command_template.rb' => 'lib/core/commands/mint/templates/programming/command_bin.rb',
  'auxiliaries/mint_aux/templates/command_templates/definition_template.rb' => 'lib/core/commands/mint/templates/programming/command_main.rb',
  'auxiliaries/mint_aux/command_generator.rb' => 'lib/core/commands/mint/modules/command_generator.rb',
  'auxiliaries/mint_aux/help.txt' => 'lib/core/commands/mint/help.md',
  'auxiliaries/mint_aux/main.rb' => 'lib/core/commands/mint/main.rb',
  # auxiliaries - outest
  'auxiliaries/outest_aux/help.md' => 'lib/core/deprecated/outest_help.md',
  'auxiliaries/outest_aux/main.rb' => 'lib/core/deprecated/outest_main.rb',
  # auxiliaries - vault
  'auxiliaries/vault_aux/help.md' => 'lib/core/commands/vault/help.md',
  'auxiliaries/vault_aux/main.rb' => 'lib/core/commands/vault/main.rb',
  # auxiliaries - wurdle
  'auxiliaries/wurdle_aux/help.md' => 'lib/core/commands/wurdle/help.md',
  'auxiliaries/wurdle_aux/main.rb' => 'lib/core/commands/wurdle/main.rb',
  'auxiliaries/wurdle_aux/constants.rb' => 'lib/core/commands/wurdle/constants.rb',
  # Spec
  'spec/auxiliaries/_command/class_extensions/numeric_spec.rb' => 'spec/core/extensions/numeric_spec.rb',
  'spec/auxiliaries/_command/class_extensions/string_spec.rb' => 'spec/core/extensions/string_spec.rb',
  'spec/auxiliaries/_command/class_extensions/object_spec.rb' => 'spec/core/extensions/object_spec.rb',
  'spec/auxiliaries/_command/modules/normalize_spec.rb' => 'spec/core/command/modules/normalize_spec.rb',
  'spec/auxiliaries/_command/modules/settings_handler_spec.rb' => 'spec/core/command/modules/settings_handler_spec.rb',
  'spec/auxiliaries/_command/command_spec.rb' => 'spec/core/command/main_spec.rb',
}.freeze

def restructure_project(structure_map)
  structure_map.each do |old_path, new_path|
    new_dir = File.dirname(new_path)
    FileUtils.mkdir_p(new_dir)

    if File.exist?(old_path)
      puts "Moving #{old_path} -> #{new_path}"
      FileUtils.mv(old_path, new_path)
    else
      puts "WARNING: #{old_path} not found."
    end
  end
end

def clean_empty_folders(base_dir)
  Dir.glob("#{base_dir}/**/").reverse_each do |dir|
    next if dir == base_dir
    if Dir.empty?(dir)
      puts "Removing empty directory: #{dir}"
      Dir.rmdir(dir)
    end
  end
end

# restructure_project STRUCTURE_MAP
clean_empty_folders('.')
