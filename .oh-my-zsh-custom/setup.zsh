# ============================================================================
# ZSH CUSTOM SETUP & COMPILATION UTILITIES
# ============================================================================
# This file contains functions for setting up, updating, and compiling
# oh-my-zsh custom plugins and scripts.

# Helper: Compile multiple zsh files
zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f" 2>/dev/null; done
}

# Helper: Process a single plugin (setup, update, compile)
# Usage: _process_plugin <path> <url> <compile_file> <mode>
_process_plugin() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh-custom}"
  local rel_path="$1"
  local url="$2"
  local compile_file="$3"
  local mode="${4:-update}"  # setup, update, or compile

  local full_path="$custom_dir/$rel_path"

  case "$mode" in
    setup)
      if [[ ! -e "$full_path" ]]; then
        echo "Cloning $(basename $rel_path)..."
        git clone --depth=1 "$url" "$full_path"
        [[ "$rel_path" == "themes/powerlevel10k" ]] && make -C "$full_path" pkg 2>/dev/null
      fi
      ;;
    update)
      if [[ -d "$full_path/.git" ]]; then
        local before=$(cd "$full_path" && git rev-parse HEAD 2>/dev/null)
        (cd "$full_path" && git pull --quiet --rebase 2>/dev/null)
        local after=$(cd "$full_path" && git rev-parse HEAD 2>/dev/null)
        [[ "$before" != "$after" ]] && return 0  # Signal that update happened
      fi
      return 1  # No update
      ;;
    compile)
      if [[ -n "$compile_file" && -f "$full_path/$compile_file" ]]; then
        zcompile-many "$full_path/$compile_file"
      fi
      ;;
  esac
}

# Helper: Iterate over all plugins
_for_each_plugin() {
  local mode="$1"
  local callback="${2:-_process_plugin}"

  $callback "plugins/fast-syntax-highlighting" "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" "fast-syntax-highlighting.plugin.zsh" "$mode"
  $callback "plugins/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions.zsh" "$mode"
  $callback "plugins/zsh-completions" "https://github.com/zsh-users/zsh-completions.git" "zsh-completions.plugin.zsh" "$mode"
  $callback "themes/powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "" "$mode"
}

# Helper: Compile plugin files (with optional cleanup)
_compile_plugins() {
  local clean="${1:-false}"

  # Clean if requested
  if [[ "$clean" = true ]]; then
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh-custom}"
    rm -f "$custom_dir"/plugins/fast-syntax-highlighting/*.zwc 2>/dev/null
    rm -f "$custom_dir"/plugins/zsh-autosuggestions/*.zwc 2>/dev/null
    rm -f "$custom_dir"/plugins/zsh-completions/*.zwc 2>/dev/null
  fi

  # Compile all plugins
  _for_each_plugin compile
}

# Helper: Generate completion files for external tools
_update_completion_files() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh-custom}"
  local completions_dir="$custom_dir/completions"
  local updated=false
  mkdir -p "$completions_dir"

  # cwctl completion
  if command -v cwctl &>/dev/null; then
    if [[ ! -f "$completions_dir/_cwctl" ]] || [[ $(command -v cwctl) -nt "$completions_dir/_cwctl" ]]; then
      echo "  Generating cwctl completion..."
      cwctl completion zsh > "$completions_dir/_cwctl" 2>/dev/null
      updated=true
    fi
  fi

  # Add more tool completions here as needed

  [[ "$updated" = true ]] && return 0
  return 1
}

# Update completion files (usually called automatically)
update-completions() {
  echo "Updating completion files..."
  _update_completion_files
  echo "✓ Completions updated!"
}

# Compile zsh custom scripts for faster loading
compilecustom() {
  echo "Compiling custom zsh scripts..."
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh-custom}"

  echo "  Cleaning existing compiled files..."
  # Delete existing .zwc files to ensure fresh compilation
  for file in "$custom_dir"/*.zsh(N); do
    [[ -f "${file}.zwc" ]] && rm -f "${file}.zwc"
  done

  # Compile custom .zsh files in the root
  for file in "$custom_dir"/*.zsh(N); do
    if [[ -f "$file" ]]; then
      echo "  Compiling $(basename $file)..."
      zcompile-many "$file"
    fi
  done

  # Clean and compile plugin files
  _compile_plugins true

  # Generate/update completion files (delete .zcompdump if any were updated)
  _update_completion_files && rm -f ~/.zcompdump* 2>/dev/null

  echo "✓ Compilation complete!"
}

# Update everything: Homebrew, plugins, themes, and oh-my-zsh
upallthethings() {
  echo "=== Updating Homebrew ==="
  brew update
  brew outdated
  brew upgrade
  brew cleanup

  echo -e "\n=== Cleaning old compiled files ==="
  fd -i -I --glob -H \*.zwc ~/.oh-my-zsh-custom -x rm
  fd -d 2 -i -I --glob -H \*.zwc -x rm

  echo -e "\n=== Updating plugins ==="
  _for_each_plugin update

  echo -e "\n=== Updating oh-my-zsh ==="
  cd ~ && omz update

  echo -e "\n=== Recompiling everything ==="
  compilecustom

  echo -e "\n✓ All updates complete! Reload your shell with: omz reload"
}

# Initial setup - clones plugins if they don't exist
setupcustom() {
  echo "=== Setting up custom plugins ==="
  _for_each_plugin setup

  echo -e "\n✓ Setup complete! Now compiling..."
  compilecustom
  echo -e "\nReload your shell with: exec zsh"
}

# Auto-compile custom scripts if needed (runs on shell startup)
_autocompile_custom() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh-custom}"

  # Only auto-compile custom .zsh files (aliases, coreweave, etc.)
  for file in "$custom_dir"/*.zsh(N); do
    if [[ -f "$file" && ( ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
      zcompile-many "$file"
    fi
  done
}

# Auto-update custom plugins (respects frequency check)
_autoupdate_custom_plugins() {
  local update_file="${ZSH_CACHE_DIR:-$HOME/.cache/oh-my-zsh}/.zsh-custom-update"
  local epoch_target=1  # Check daily (matches omz update frequency)

  # Check if it's time to update
  if [[ -f "$update_file" ]]; then
    local last_update=$(cat "$update_file")
    local current_epoch=$(( $(date +%s) / 86400 ))
    local days_since=$((current_epoch - last_update))

    if (( days_since < epoch_target )); then
      return 0  # Not time yet
    fi
  fi

  # Auto-setup missing plugins, then update all
  _for_each_plugin setup

  # Update plugins and track if any changed
  local updated=false
  _update_check() {
    _process_plugin "$@" && updated=true
  }
  _for_each_plugin update _update_check

  # If anything updated, recompile and regenerate completions
  if [[ "$updated" = true ]]; then
    _compile_plugins
    rm -f ~/.zcompdump* 2>/dev/null
  fi

  # Update timestamp
  echo $(( $(date +%s) / 86400 )) > "$update_file"
}

# Run auto-compilation on shell startup
_autocompile_custom

# Run auto-update for custom plugins (silent, daily check)
# Only spawn background process if it's time to update
() {
  local update_file="${ZSH_CACHE_DIR:-$HOME/.cache/oh-my-zsh}/.zsh-custom-update"
  local epoch_target=1
  local should_update=true

  if [[ -f "$update_file" ]]; then
    local last_update=$(cat "$update_file")
    local current_epoch=$(( $(date +%s) / 86400 ))
    local days_since=$((current_epoch - last_update))
    (( days_since < epoch_target )) && should_update=false
  fi

  [[ "$should_update" = true ]] && _autoupdate_custom_plugins &!
}
