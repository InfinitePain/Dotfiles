#-----------------------------
# General Shell Settings
#-----------------------------

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
bindkey -v

bindkey '^R' history-incremental-search-backward

# Warp unsupported settings
if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    bindkey '^K' history-search-backward
    bindkey '^J' history-search-forward
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Detect OS and distribution
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_ID=$ID
    OS_ID_LIKE=$ID_LIKE
elif [[ -f /etc/debian_version ]]; then
    OS_ID="debian"
    OS_ID_LIKE="debian"
else
    OS_ID="unknown"
    OS_ID_LIKE="unknown"
fi

# Detect available package managers
HAS_PACMAN=0
HAS_APT=0
HAS_DNF=0

command -v pacman >/dev/null 2>&1 && HAS_PACMAN=1
command -v apt >/dev/null 2>&1 && HAS_APT=1
command -v dnf >/dev/null 2>&1 && HAS_DNF=1

# Set up oh-my-posh if available
if command -v oh-my-posh >/dev/null 2>&1; then
    if [[ -f ~/.config/oh-my-posh/themes/infinite.omp.yml ]]; then
        eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/infinite.omp.yml)"
    else
        # Fallback to a theme that comes with oh-my-posh if our custom one isn't available
        eval "$(oh-my-posh init zsh)"
    fi
else
    # Fallback if oh-my-posh isn't available
    PROMPT='[%n@%m %~]$ '
fi

# Pacman-specific settings
if [[ $HAS_PACMAN -eq 1 ]]; then
    # Rehash zsh's hash table on receiving USR1, useful with pacman hook 
    # to update command paths.
    TRAPUSR1() { rehash }
fi

# Source/Load zinit if Git is available
if command -v git >/dev/null 2>&1; then
    ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    # Download Zinit, if it's not there yet
    if [ ! -d "$ZINIT_HOME" ]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" || \
        echo "Warning: Failed to clone zinit repository"
    fi

    if [ -d "$ZINIT_HOME" ]; then
        source "${ZINIT_HOME}/zinit.zsh"

        zinit light zsh-users/zsh-syntax-highlighting
        zinit light Aloxaf/fzf-tab
        zinit snippet OMZP::sudo
    fi
fi

# Load fzf integration if available
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

#-----------------------------
# Environment Variables
#-----------------------------

export EDITOR=nano
export SUDO_PROMPT="$(tput setab 1 setaf 7 bold)[sudo]$(tput sgr0) password for $(tput setaf 5)%p$(tput sgr0): "

#-----------------------------
# Aliases
#-----------------------------

if command -v eza >/dev/null 2>&1; then
    # If eza is installed, use it
    alias ls='eza --hyperlink --icons=always --group-directories-first --group --header'
else
    # Fallback to standard ls
    alias ls='ls --hyperlink --color=auto --group-directories-first'
fi

alias grep='grep --color=auto'
alias boot-bios='systemctl reboot --firmware-setup'
alias boot-list='systemctl reboot --boot-loader-entry=help'
alias boot-from='f() { systemctl reboot --boot-loader-entry=$1; }; f'
alias ip='ip -color'
alias ipv4='ip -o -4 -br addr show'
alias ipv6='ip -o -6 -br addr show'

#-----------------------------
# Completion System
#-----------------------------

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' ignore-parents parent pwd directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' original false
zstyle ':completion:*' squeeze-slashes true
zstyle :compinstall filename "$HOME/.zshrc"

# Only set up advanced completion if we have zinit
if [ -d "$ZINIT_HOME" ]; then
    # Set up fzf-tab only if both fzf and zinit are available
    if command -v fzf >/dev/null 2>&1; then
        # Basic fzf-tab configuration
        zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse

        # Enhanced file, directory, and image preview
        zstyle ':fzf-tab:complete:*:*' fzf-preview '
        if [[ -f $realpath ]]; then
            case $(file --mime-type -b "$realpath") in
            image/png|image/jpeg|image/jpg|image/gif)
                if [[ "$TERM" == "xterm-kitty" ]]; then
                    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0" "$realpath" 2>/dev/null
                else
                    echo "Image: $realpath (Preview only available in kitty terminal)"
                fi
                ;;
            text/*)
                if command -v bat >/dev/null 2>&1; then
                    bat --style=numbers --color=always "$realpath" 2>/dev/null
                else
                    cat "$realpath"
                fi
                ;;
            *)
                file -b "$realpath" 2>/dev/null || echo "Unknown file type"
                ;;
            esac
        elif [[ -d $realpath ]]; then
            if command -v eza >/dev/null 2>&1; then
                eza --tree --level=1 --hyperlink --icons=always --color=always --group-directories-first "$realpath" 2>/dev/null
            else
                ls -l --color=always --hyperlink --group-directories-first "$realpath" 2>/dev/null
            fi
        else
            echo "No preview available"
        fi'

        # Specific preview for cd command
        zstyle ':fzf-tab:complete:cd:*' fzf-preview '
        if [[ -d $realpath ]]; then
            if command -v eza >/dev/null 2>&1; then
                eza --tree --level=1 --hyperlink --icons=always --color=always--group-directories-first "$realpath" 2>/dev/null
            else
                ls -l --color=always --hyperlink --group-directories-first "$realpath" 2>/dev/null
            fi
        else
            echo "Not a directory"
        fi'

        # Preview position
        zstyle ':fzf-tab:*' fzf-pad 4
        zstyle ':fzf-tab:*' fzf-preview-position left

        # Enable continuous preview refresh
        zstyle ':fzf-tab:*' continuous-trigger 'ctrl-space'

        # Group completions by type
        zstyle ':fzf-tab:*' group-colors 'default=1;38;5;7:prefix=1;38;5;7:description=1;38;5;15'
    fi

    autoload -Uz compinit

    zinit light zsh-users/zsh-completions
    zinit light zsh-users/zsh-autosuggestions

    compinit
    zinit cdreplay -q
else
    # Basic completion without zinit
    autoload -Uz compinit
    compinit
fi

# pipx completions (only if pipx is available)
if command -v register-python-argcomplete >/dev/null 2>&1 && command -v pipx >/dev/null 2>&1; then
    autoload -U bashcompinit && bashcompinit
    eval "$(register-python-argcomplete pipx)"
fi

#-----------------------------
# Functions
#-----------------------------

# Package manager specific functions
if [[ $HAS_PACMAN -eq 1 ]]; then
    # Suggests packages for missing commands using `pacman`
    function command_not_found_handler {
        local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
        printf 'zsh: command not found: %s\n' "$1"
        local entries=(
            ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"}
        )
        if (( ${#entries[@]} ))
        then
            printf "${bright}$1${reset} may be found in the following packages:\n"
            local pkg
            for entry in "${entries[@]}"
            do
                # (repo package version file)
                local fields=(
                    ${(0)entry}
                )
                if [[ "$pkg" != "${fields[2]}" ]]
                then
                    printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
                fi
                printf '    /%s\n' "${fields[4]}"
                pkg="${fields[2]}"
            done
        fi
        return 127
    }
elif [[ $HAS_APT -eq 1 ]]; then
    # Suggests packages for missing commands on Debian/Ubuntu
    # If the command-not-found package is installed, use it
    if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
        function command_not_found_handler {
            # Check as it might be removed in the meantime
            if [ -x /usr/lib/command-not-found ]; then
            /usr/lib/command-not-found -- "$1"
            return $?
            elif [ -x /usr/share/command-not-found/command-not-found ]; then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
            else
            printf "zsh: command not found: %s\n" "$1" >&2
            return 127
            fi
        }
    fi
fi

# Generate a list of even numbers within a specified range
function evens() {
    local start end format="space"
    for arg in "$@"; do
        case $arg in
            newline|comma) format=$arg ;;
            *) if [[ -z $start ]]; then start=$arg; else end=$arg; fi ;;
        esac
    done
    [[ $start -gt $end ]] && { local temp=$start; start=$end; end=$temp; }
    if [[ $format == "newline" ]]; then
        seq $start $end | awk '($1 % 2 == 0)'
    elif [[ $format == "comma" ]]; then
        seq $start $end | awk '($1 % 2 == 0)' | paste -sd, -
    else
        seq $start $end | awk '($1 % 2 == 0)' | paste -sd " " -
    fi
}

# Generate a list of even numbers within a specified range
function odds() {
    local start end format="space"
    for arg in "$@"; do
        case $arg in
            newline|comma) format=$arg ;;
            *) if [[ -z $start ]]; then start=$arg; else end=$arg; fi ;;
        esac
    done
    [[ $start -gt $end ]] && { local temp=$start; start=$end; end=$temp; }
    if [[ $format == "newline" ]]; then
        seq $start $end | awk '($1 % 2 != 0)'
    elif [[ $format == "comma" ]]; then
        seq $start $end | awk '($1 % 2 != 0)' | paste -sd, -
    else
        seq $start $end | awk '($1 % 2 != 0)' | paste -sd " " -
    fi
}

# Load local configuration if exists
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi