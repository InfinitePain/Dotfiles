#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

alias boot-bios='systemctl reboot --firmware-setup'
alias boot-list='systemctl reboot --boot-loader-entry=help'
alias boot-from='f() { systemctl reboot --boot-loader-entry=$1; }; f'

DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Created by `pipx` on 2023-12-21 00:58:19
export PATH="$PATH:/home/emirhan/.local/bin"
eval "$(register-python-argcomplete pipx)"

export SUDO_PROMPT="$(tput setab 1 setaf 7 bold)[sudo]$(tput sgr0) password for $(tput setaf 5)%p$(tput sgr0): "
export EDITOR=nano

function ipv4() {
    max=$(ip -o -4 addr show | awk '{print length($2)}' | sort -nr | head -n1)
    
    ip -o -4 addr show | awk -v max=$max '
    {
        gsub("inet", "IPv4")
        printf "%*s - %s: %s\n", max+1, $2, $3, $4
    }'
}

function ipv6() {
    max=$(ip -o -6 addr show | awk '{print length($2)}' | sort -nr | head -n1)
    
    ip -o -6 addr show | awk -v max=$max '
    {
        gsub("inet6", "IPv6")
        printf "%*s - %s: %s\n", max+1, $2, $3, $4
    }'
}

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
