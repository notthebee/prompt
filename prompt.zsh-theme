#!/usr/bin/env zsh

# (-U autoload w/o substition, -z use zsh style)
autoload -Uz add-zsh-hook vcs_info

# Set prompt substitution so we can use the vcs_info_message variable
setopt prompt_subst

# Run the `vcs_info` hook to grab git info before displaying the prompt
add-zsh-hook precmd vcs_info

# Style the vcs_info message
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%b%u%c'
# Format when the repo is in an action (merge, rebase, etc)
zstyle ':vcs_info:git*' actionformats '%F{14}⏱ %*%f'
zstyle ':vcs_info:git*' unstagedstr '*'
zstyle ':vcs_info:git*' stagedstr '+'
# This enables %u and %c (unstaged/staged changes) to work,
# but can be slow on large repos
zstyle ':vcs_info:*:*' check-for-changes true

host() {
    case "%m" in
      meredith) color=blue ;;
      emily) color=green ;;
      spencer) color=yellow ;;
      alison) color=magenta ;;
      *) color=blue ;;
    esac
    echo "%F{$color}%m%f"
}

function collapse_pwd {
    echo $(pwd | sed -e "s,^$HOME,~,")
}

function truncated_pwd() {
  n=$1 # n = number of directories to show in full (n = 3, /a/b/c/dee/ee/eff)
  path=`collapse_pwd`

  # split our path on /
  dirs=("${(s:/:)path}")
  dirs_length=$#dirs

  if [[ $dirs_length -ge $n ]]; then
    # we have more dirs than we want to show in full, so compact those down
    ((max=dirs_length - n))
    for (( i = 1; i <= $max; i++ )); do
      step="$dirs[$i]"
      if [[ -z $step ]]; then
        continue
      fi
      if [[ $step =~ "^\." ]]; then
        dirs[$i]=$step[0,2] #make .mydir => .m
      else
        dirs[$i]=$step[0,1] # make mydir => m
      fi
      
    done
  fi

  echo ${(j:/:)dirs}
}

status_symbol() {
    echo •
}

status_ok() {
    echo "%F{green}$(status_symbol)%f"
}

status_err() {
    echo "%F{red}$(status_symbol)%f"
}

return_status() {
    echo "%(?:$(status_ok):$(status_err))"
}

prompt_indicator() {
    indicator="~"
    [[ $UID -eq 0 ]] && indicator="#"
    echo "%F{blue}%B$indicator%b%f"
}

vcs_info() {

}

GIT='%F{8}⎇ ${vcs_info_msg_0_}%f'

ZSH_THEME_GIT_PROMPT_PREFIX=" %B%F{white}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{white})%f%b"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='$(return_status) $(host)$(git_prompt_info) $(prompt_indicator) '
RPROMPT='%F{8}$(truncated_pwd 2)%f'
