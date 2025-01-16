# Command Project Documentation

## Overview

The Command project is designed to simplify the creation and management of shell commands in Ruby. By providing a `Command` class as the foundation, it allows developers to create commands with consistent features, handling boilerplate functionality while enabling custom behavior.

This project mimics traditional Unix commands like `cat` or `ls`, using a similar syntax and is intended to work seamlessly by adding your folder of commands to the system's PATH. Commands leverage strict flags (referred to as `Modes`), flexible keyword inputs (`Settings`), and robust error handling for intuitive and error-resistant use.

---

## Structure

### The `Command` Class

The `Command` class is the backbone of this project. It includes the following key features:

- **Modes**: Explicit flags for primary control over the command's operation (e.g., `-n`, `--number`). These are validated strictly and must start with one or two dashes.
- **Settings**: Mutable global attributes or states, defaulted to predefined values. Unlike Modes, these do not require dashes and are more flexible.
- **Adjustments**: A subset of Settings that are optional and dependent on the current Mode.
- **Parameters**: Positional arguments for commands, required for many operations.
- **Error Handling**: Managed using the `CommandErrors` module for consistent and clear exception handling.

The class is meant to be extended, providing child classes with the structure to implement specific command functionality.

---

## Core Modes

The following Modes are available by default in every Command:

- **bypass**: For testing only, can be used to satisfy a single mode flag check. Aliases: `-b+`, `--bypass`.
- **configure**: Not yet implemented, intended to access the Command's configuration file. Aliases: `-c+`, `--configure`.
- **help**: Displays the command's `help.md` file, if available. Otherwise, prints a list of modes and their flags and aliases. Aliases: `-h+`, `-man`, `--manual`, `-m+`, `--help`.
- **inspect**: Can be used to see the internal state of the command during execution. Prints a list of inputs, settings, and states. Aliases: `-i+`, `--inspect`.
- **reset**: Not yet implemented, meant to reset the config file to default settings. Aliases: `-r+`, `--reset`.

### Input Validation

The `Command` class validates Modes with a strict pattern to ensure clarity and consistency. The full pattern used is:

```ruby
/(^-[A-Za-z]{1,3}\+?$)|(^--[A-Za-z][A-Za-z0-9_]+$)/
```

- **Short Mode**: Begins with a single dash (`-`), followed by 1-3 letters. An optional `+` is allowed at the end.
- **Long Mode**: Begins with two dashes (`--`), followed by a single letter and alphanumeric characters or underscores.

The `Settings` pattern is:

```ruby
/\w+:[\w/.-]+/
```

Inputs that do not match either the `Modes` or `Settings` patterns are treated as `Parameters`.

#### Example: `--inspect` Mode

```plaintext
INSPECTION MODE:
  RAW: ["-i+"]
  TOKENS:
    modes     : [:inspect]
    settings  : {}
    parameters: []
  STATE:
    modes     : [:inspect]
    settings  : {...}
      active_mode        : addition
      core_modes         : [:inspect]
      input_modes        : []
      case_sensitivity   : [:settings]
      default_mode       : addition
      mode_limit         : 0..2
      parameter_limit    : 1..9
      execution_directory: <NIL>
      send_directory     : <NIL>
      digits             : 1
      operator_digits    : 1
      questions          : 10
      answers            : true
      negative           : 0
    parameters: []
```

---

## Getting Started

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/command-project.git
   ```
2. Add the `commands` directory to your PATH:
   ```bash
   export PATH=$PATH:/path/to/command-project/commands
   ```
3. Install dependencies:
   ```bash
   bundle install
   ```

### Creating a New Command

1. Create a new Ruby file inheriting from `Command`:
   ```ruby
   require_relative 'path_to_command_class'

   class YourCommand < Command
     def run    
       # Define behavior here
     end
   end
   ```
2. Save the file in the `commands` directory.
3. Test your new command:
   ```bash
   $ your_command --help
   ```

### Automatically Generating Commands with `forge`

You can use the `forge` command to create a new script with all necessary boilerplate:

```bash
forge type:script command_name
```

This will:
- Create a `/lib` folder, `main.rb`, and auxiliary resources.
- Generate a `/bin` executable with execution permissions.
- Use templates for the exec and main files, pre-injecting the script name so you can start coding immediately.

This simplifies and streamlines the process, ensuring a consistent and ready-to-use environment for your script development.

