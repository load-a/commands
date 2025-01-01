# Forge

A Command for creating, deleting, and copying files.

## Modes
### Core Modes
- Bypass: used to bypass the mode check in testing.
- Configure: applies the input settings to Forge's config file.
- Help: Shows this file, along with the flags for each mode
- Inspect: Shows the working data for the current run of the command.
- Reset: resets the config file.
- 
### Forge Modes
- Make: file creation. [Default]
- Remove: file deletion.
- Copy: file copying.

## Settings
### Core Settings
- Active Mode: The current mode being run.
- Core Modes: The core modes triggered by user input.
- Input Modes: The Forge modes triggered by the user.
- Case Sensitivity: The inputs which are case sensitive.
- Execution Directory: Where the program runs.
- Send Directory: Where the program sends the results of its work, if applicable.
- Mode Limit: The number of modes required by the program.
- Parameter Limit: The number of parameters needed by the program

### Forge Settings
#### Make
- Type: Which template type to use (ruby, java, bash, etc.)
- Subtype: Which specific template to use (Java Class vs Java Main, for instance.)

#### Remove
- Check: the number of files needed to trigger the Removal Confirmation
- Directory: Whether the directory containing the file should be removed once the file is deleted.