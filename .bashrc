# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='[\t] ${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is a screen/tmux then we have a special prompt
if [ "$TERM" = screen ]; then
    PS1='[\t] ${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export VAULT_ADDR=http://qatools.cudaops.com:8200
export KUBE_IMAGES_DIR=/home/kmchang/repos/docker-cloud-services/kubernetes/
export KUBERNETES_ADMIN_CONF=/home/kmchang/repos/cuda-provision/kubernetes_admin.conf

# Add Static Routes for accessing stuff from the VPN
add_vpn_route() {
    if [ -z "$1" ]; then
        echo "Usage: add_vpn_route <IP_OR_HOSTNAME> [ PORT ]" >&2
        return 1
    fi

    IP_OR_HOSTNAME="$1"

    # assume ssh port
    PORT_CHECK=${2:-22}

    if [ -z "$VPN_GW" ]; then
        if [ "$(uname)" = "Darwin" ]; then
            IFACE=$(route -n get 10.8.1.91 | perl -ne 'print $1 if m{interface: ((?:ppp|tun|tap)\d+)}')
            VPN_GW=$(netstat -rn -f inet | awk "/$IFACE\$/ && / 10\.8/ { print \$2 }" | head -1)
        else
            VPN_GW=$(ip route get 10.8.1.91 | perl -ne 'print $1 if m{via ([\d.]+) dev (?:tun|ppp|tap)\d+}')
        fi
    fi

    if [ -z "$VPN_GW" ]; then
       echo "Can't find VPN gateway to add route for $IP" >&2
       echo "Set the VPN_GW environment variable to skip attempted auto-detection" >&2
       return 1
    fi

    if [[ "$IP_OR_HOSTNAME" =~ ^[a-zA-Z] ]]; then
        IP_OR_HOSTNAME=$(dig +short "$IP_OR_HOSTNAME" | grep -v '\.$')
    fi

    GW_ARG=gw
    if [ "$(uname)" = "Darwin" ]; then
        GW_ARG=
    fi

    for IP in $IP_OR_HOSTNAME; do
        # may need a static route through the VPN
        if ! nmap -p $PORT_CHECK -Pn $IP | grep -q open && ! $NETSTAT | grep -q $IP; then
            echo "Couldn't reach $IP:$PORT_CHECK, adding route via $VPN_GW"
            echo "(you may need to enter pw for 'sudo route')"
            sudo route add $IP/32 $GW_ARG $VPN_GW
        else
            echo "$IP:$PORT_CHECK is reachable"
        fi
    done
}

# Useful Shortcuts
alias untar='tar -zxvf'
alias activate-venv='source ~/envs/$(basename $(pwd))/bin/activate'

# Some BBS Shortcuts
alias perf-1090='ssh root@10.66.5.2'

# VPN Shortcuts
alias vpn-up='barracudavpn --start -l kmchang; add_vpn_route login.qa.cudaops.com'
alias vpn-down='barracudavpn --stop'

# Storage Test
alias st-tmux='tmux a -t storage-test'
alias st-up='~/storage-test-tmux.sh'
alias st-enter='docker-compose -f ~/repos/storage-test/docker-compose.yml  exec storage-test /bin/bash'
# Open the most recent screenshot
alias feh-ss='feh /home/kmchang/repos/storage-test/screenshots/`ls /home/kmchang/repos/storage-test/screenshots/ | tail -n1`'

# Autocomplete for vault
complete -C /usr/local/bin/vault vault
