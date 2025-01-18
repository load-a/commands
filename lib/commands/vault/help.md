VAULT - Obsidian Vault Management Tool

SYNOPSIS
    vault [MODE] <VAULT_NAME> [PARAMETERS...] [SETTINGS...]

DESCRIPTION
    The Vault command is a tool for managing Obsidian vaults and their configurations. It provides functionality to create, delete, rename, synchronize, and back up vaults. While other commands allow dynamic settings, Vault's settings are static and preconfigured to ensure simplicity.

INPUT TYPES
    Vault commands support three distinct input types:
      - Modes: Specify the operation to be performed. Must match a valid mode or alias.
      - Parameters: Additional freeform inputs, such as vault names, filenames, or paths.
      - Settings: Locked for this command. Cannot be overridden or provided dynamically.

    Inputs are generally not positional, except in `rename` mode where the first vault name is the old name, and the second is the new name.

DEFAULTS
    If no mode flag is provided, Vault defaults to the `make` mode.

MODES
    Here is the list of available modes, along with their associated flags and aliases:

    make:
      ["-m", "-mk", "-new", "-w", "--new", "--write", "--create", "--make"]
      Creates a new vault. Initializes it with:
        - A `.obsidian` folder copied from the master configuration.
        - A default Markdown file named after the vault.
      Example:
          vault -m my_new_vault

    remove:
      ["-r", "-rm", "-d", "-del", "--delete", "--remove"]
      Deletes a vault and all its contents. Confirmation required.
      Example:
          vault -r old_vault

    rename:
      ["-n", "-mv", "-rn", "--name", "--move", "--rename"]
      Renames a vault. Provide the old name and the new name as parameters.
      Example:
          vault -n old_name new_name

    update:
      ["-u", "-get", "--pull", "--get", "--update"]
      Updates a vault's `.obsidian` folder using the master configuration.
      Example:
          vault -u existing_vault

    push:
      ["-p", "--push", "--give", "--push"]
      Overwrites the master configuration with the `.obsidian` folder from a vault. Confirmation required.
      Example:
          vault -p my_special_vault

    save:
      ["-s", "--save"]
      Saves a vault’s `.obsidian` folder to a `.backup` folder. (If no vault is specified the Master Config Folder will be used.)
      Example:
          vault -s important_vault

    load:
      ["-l", "--load"]
      Restores a vault’s `.obsidian` folder from its `.backup` folder. (If no vault is specified the Master Config Folder will be used.)
      Example:
          vault -l archived_vault

SETTINGS
    Vault's settings are static and cannot be changed dynamically. The following are preconfigured:
      - `execution_directory`: The script's location.
      - `send_directory`: The Obsidian vault root folder.
      - `case_sensitivity`: Settings and parameters are case-sensitive.
      - `parameter_limit`: A maximum of 2 parameters are allowed.
      - `mode_limit`: A maximum of 2 modes are allowed.

NOTES
    - Inputs can be provided in any order (except `rename` mode parameters).
    - Modes require confirmation for destructive actions like `remove` and `push`.
    - Static settings ensure consistent functionality and behavior across vault operations.
    - Settings are not customizable in this command but may be in others.

SEE ALSO
    Other tools in the `Command` suite, your Obsidian configuration documentation, or relevant script documentation for integrating Vault with additional workflows.

HELP
    For more information, run: vault -h
