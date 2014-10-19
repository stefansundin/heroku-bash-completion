# https://github.com/stefansundin/heroku-bash-completion

# Based on:
# https://github.com/daveyeu/heroku-bash-completion/blob/master/heroku-bash-completion.sh
# https://github.com/rafmagana/heroku_bash_completion/blob/master/heroku_bash_completion.sh

# TODO:
# Regenerate .heroku/completion when heroku version changes or plugin is installed

# If you get errors about _split_longopt or __ltrim_colon_completions, be sure to install bash-completion.
# brew install bash-completion
# And put this in .bash_profile
# if [ -f $(brew --prefix)/etc/bash_completion ]; then
#   . $(brew --prefix)/etc/bash_completion
# fi
# source ~/heroku-completion.bash


_heroku_complete() {
  COMPREPLY=( $( compgen -W "$1" -- "$cur" ))
}

_heroku_commands() {
  if [[ ! -f ~/.heroku/completion ]]; then
    >&2 echo -e "\nLoading completion data, this may take a minute."

    local commands=(`heroku help | grep '#' | awk 'NF { print $1; }'`)
    local subcommands=()

    for i in "${commands[@]}"; do
      >&2 echo "Loading subcommands for $i."
      subcommands+=(`heroku help "$i" | grep '#' | grep -v '-' | awk 'NF { print $1; }'`)
    done

    # Concatenate commands and subcommands
    cmds=( "${commands[@]}" "${subcommands[@]}" )

    # Delete deprecated commands from the list, most no longer even works.
    delete=(run:console run:rake)
    for del in ${delete[@]}
    do
      cmds=(${cmds[@]/$del})
    done

    # Add missing commands
    # 2fa:disable should be twofactor:disable, report this problem upstream?
    cmds+=(twofactor:disable)

    # Write .heroku/completion
    ( IFS=$'\n'; echo -e "${cmds[*]}" > ~/.heroku/completion )
  fi
  cat ~/.heroku/completion
}

_heroku_apps() {
  if [[ ! -f ~/.heroku/completion-apps ]]; then
    >&2 echo -e "\nLoading list of apps, this will take a few seconds."
    heroku apps | grep -v '=' | cut -d' ' -f1 | awk 'NF' > ~/.heroku/completion-apps
  fi
  cat ~/.heroku/completion-apps
}

_heroku_apps_short() {
  echo "$(_heroku_apps)" | awk '{{print "-a"$1}}'
}

_heroku_main_commands() {
  echo "$(_heroku_commands)" | grep -v ':'
}

_heroku_subcommands_regex() {
  echo "$(_heroku_commands)" | grep -v "help|version" | tr "\n" "|"
}

_heroku_remotes() {
  # This regex looks complicated but it only is due to a tab being in there, and we use the $'\t' trick
  git remote -v 2>/dev/null | sed -n 's/\(.*\)'$'\t''.*heroku\.com.*(push)/\1/p'
}

_heroku_remotes_short() {
  echo "$(_heroku_remotes)" | awk '{{print "-r"$1}}'
}

_rake_tasks() {
  local gitroot=`git rev-parse --show-toplevel 2> /dev/null`
  [ -z "$gitroot" ] && return
  if [[ ! -f ~/.heroku/completion-rake || `cat ~/.heroku/completion-rake | grep "$gitroot:"` == "" ]]; then
    >&2 echo -e "\nLoading list of rake tasks, this will take a few seconds."
    echo "$gitroot: `rake -s -T 2>/dev/null | awk '{{print $2}}' | tr "\n" " "`" >> ~/.heroku/completion-rake
  fi
  cat ~/.heroku/completion-rake | grep "$gitroot:" | cut -d' ' -f2-
}

_heroku() {
  local cur prev split=false
  COMPREPLY=()
  _get_comp_words_by_ref cur prev
  _split_longopt && split=true

  case $prev in
    version)
      return 0
      ;;
    -r|--remote)
      _heroku_complete "$(_heroku_remotes)"
      return 0
      ;;
    -a|--app)
      _heroku_complete "$(_heroku_apps)"
      return 0
      ;;
    run)
      _heroku_complete "rails rake"
      return 0
      ;;
    rails)
      _heroku_complete "console"
      return 0
      ;;
    rake)
      # e.g. heroku run rake db:seed
      _heroku_complete "$(_rake_tasks)"
      __ltrim_colon_completions "$cur"
      return 0
      ;;
  esac

  $split && return 0

  if [[ $cur =~ ^(-a) ]]; then
    _heroku_complete "$(_heroku_apps_short)"
  elif [[ $cur =~ ^(-r) ]]; then
    _heroku_complete "$(_heroku_remotes_short)"
  elif [[ $cur =~ ^(-|--) ]]; then
    _heroku_complete "--app --remote"
  elif [[ $cur =~ ^($(_heroku_subcommands_regex)fargle) ]]; then
    _heroku_complete "$(_heroku_commands)"
  # elif [[ $prev != "heroku" ]]; then
  #   >&2 echo ""
  #   heroku help "$prev" >&2
  else
    _heroku_complete "$(_heroku_main_commands)"
  fi
  __ltrim_colon_completions "$cur"
  return 0
}

# Use the commented version if you want spaces to be added, but this doesn't allow you to autocomplete the colon for subcommands
complete -o nospace -F _heroku heroku
# complete -F _heroku heroku
