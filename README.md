# Dotfiles and Configuration Files

Welcome to my collection of dotfiles and configuration files! These files help me customize and personalize my development environment across different systems. By using version control to manage these files, I can easily synchronize my settings and preferences between machines.

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Customization](#customization)
- [Maintenance](#maintenance)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## Introduction

Dotfiles are configuration files that begin with a dot (e.g., `.bashrc`, `.vimrc`) and are typically located in the user's home directory. This repository contains my personalized dotfiles and various configuration files for tools and applications I use regularly. The primary goal of this repository is to streamline the setup process and ensure consistency across my development environments.

Feel free to explore, use, and adapt these dotfiles to suit your preferences. However, be cautious when replacing your existing configuration files as it may affect your system's behavior.

## Getting Started

To get started with these dotfiles, follow these simple steps:

1. **Clone the repository:** Clone this repository to your local machine using `git`.

   ```bash
   git clone https://github.com/onirutlA/dotfiles.git
   cd dotfiles
   ```

2. **Review and backup existing files:** Before applying these dotfiles, ensure you have a backup of your existing configuration files. This way, you can easily revert to the previous state if necessary.

3. **Symlink the dotfiles:** Create symbolic links for each dotfile in this repository to your home directory.

   ```bash
   ln -s ~/dotfiles/.bashrc ~/.bashrc
   ln -s ~/dotfiles/.vimrc ~/.vimrc
   # Add more links as needed for other dotfiles
   ```
   or you can use GNU Stow
   ```bash
   # make sure you are in dotfiles directory
   stow *
   ```

5. **Install required dependencies:** Some dotfiles may depend on specific applications or plugins. Make sure to install them to leverage the full potential of these configurations. Here are the dependency for the config file:
  - fzf
  - ripgrep

That's it! Your development environment should now be set up with the custom configurations from this repository.

## Usage

This section describes how each of the essential dotfiles is organized and used:

### `alacrity.yml`

The `alacrity.yml` file contains terminal settings, theme, fonts, and etc that enhance the command-line experience. After making changes to this file, remember to reload it using `source /.config/alacrity/alacrity.yml` for the changes to take effect.

### `.bashrc`

The `.bashrc` file contains various shell settings, aliases, and environment variables that enhance the command-line experience. After making changes to this file, remember to reload it using `source ~/.bashrc` for the changes to take effect.

### `.ideavimrc`

The `.ideavimrc` file is the configuration file for IdeaVim plugin. It contains customizations of keybinding and mostly for Android Development. If you're new to Vim, you may want to explore the provided configurations and customize them according to your preferences.

### `nvim`

The nvim directory is the configuration file for the Neovim text editor. It is based on [NvChad](https://nvchad.com/) It includes customizations for syntax highlighting, indentation, plugins, and other settings. If you're new to Vim, you may want to explore the provided configurations and customize them according to your preferences.

### `.zshrc`

The `.zshrc` file contains various shell settings, aliases, and environment variables that enhance the command-line experience. After making changes to this file, remember to reload it using `source ~/.zshrc` for the changes to take effect.

### `.tmux.conf`

The `.tmux.conf` file contains configurations for the Tmux terminal multiplexer. Tmux allows you to create multiple terminal sessions within a single window, enhancing your productivity when working on the command line.

## Customization

Feel free to customize any of the dotfiles and configurations to suit your specific needs. Each file is well-commented, making it easier to understand the purpose of each section. Additionally, you can add new dotfiles or configurations and update the documentation accordingly.

## Maintenance

As I continue to improve and modify my configurations, I'll update this repository regularly. To keep your configurations up-to-date, follow these steps:

1. **Fetch the latest changes:** Run the following command to fetch the latest changes from the repository.

   ```bash
   git fetch origin
   ```

2. **Merge the changes:** If you haven't made any customizations, you can safely merge the updates.

   ```bash
   git merge origin/main
   ```

3. **Resolve conflicts:** If there are any conflicts, manually resolve them and commit the changes.

4. **Reload configurations:** Apply the changes using the appropriate method (e.g., `source ~/.bashrc`, `tmux source-file ~/.tmux.conf`).

## Contributing

Contributions to this repository are welcome! If you find any issues, have suggestions for improvements, or want to add new features, feel free to open an issue or submit a pull request. Please follow the existing coding style and maintain clear commit messages.

## Acknowledgements

I'd like to express my gratitude to the open-source community and developers who have contributed their dotfiles and configuration files. This repository is inspired by their work, and I encourage you to explore other repositories to find more useful configurations.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the code in accordance with the terms of this license.
