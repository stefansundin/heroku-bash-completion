# https://github.com/stefansundin/heroku-bash-completion
# Be sure to have bash-completion installed and loaded already.

# Based on:
# https://github.com/daveyeu/heroku-bash-completion/blob/master/heroku-bash-completion.sh
# https://github.com/rafmagana/heroku_bash_completion/blob/master/heroku_bash_completion.sh

# echo $COMP_WORDBREAKS
# Mac: "'><=;|&(:
# Linux:

_heroku_complete() {
  COMPREPLY=( $( compgen -W "$1" -- "$cur" ))
}

_heroku_opt() {
  COMPREPLY=( $( compgen -W "$1" -P "$opt" -- "$val" ))
}

_heroku_touch() {
  # Touch autoupdate.last to prevent heroku from trying to check for updates and thus ruining our processing
  mkdir ~/.heroku 2> /dev/null
  touch ~/.heroku/autoupdate.last
}

_heroku_data() {
  local fn=$(_heroku_plugin_path)/data/completion.txt
  if [[ ! -f "$fn" ]]; then
    >&2 echo -e "\nLoading completion data, this may take a minute."
    _heroku_touch

    local commands_temp=( $(heroku help | grep '#' | awk '{ print $1 }') )
    local commands=()

    for c in "${commands_temp[@]}"; do
      [[ $c == help ]] && continue # skip help because it has help for non-existant commands

      >&2 echo "Loading commands and switches for $c."
      local help=$(heroku help "$c" | grep '#' | cut -d'#' -f1)
      local subcommands=( $(echo "$help" | grep '^  ' | grep -v ' -' | awk '{ print $1 }') )
      local switches=( $(echo "$help" | grep -oE -- '[ ,]--?[a-zA-Z\-]+' | tr -d ' ,' | uniq | grep -ve '^\(--app\|-a\|-r\|--remote\)$') )
      commands+=( "$(echo $c ${switches[*]})" ) # echo removes trailing spaces

      # Loop through subcommands to look for switches
      for s in "${subcommands[@]}"; do
        # Fix bugs in documentation
        [[ $s == feature:enable ]] && s="features:enable"
        [[ $s == 2fa:disable ]]    && s="twofactor:disable"
        # Skip deprecated commands
        [[ $s == run:console ]]    && continue
        [[ $s == run:rake ]]       && continue

        local switches=( $(heroku help $s | grep '#' | cut -d'#' -f1 | grep -oE -- '[ ,]--?[a-zA-Z\-]+' | tr -d ' ,' | uniq | grep -ve '^\(--app\|-a\|-r\|--remote\)$' | tr '\n' ' ') )
        commands+=( "$(echo $s ${switches[*]})" ) # echo removes trailing spaces
      done
    done

    # Add secret shortcuts
    commands+=( help ) # add help because we skipped it above
    # commands+=(login logout create destroy)

    # Write .heroku/completion
    ( IFS=$'\n'; echo "${commands[*]}" > "$fn" )
    >&2 echo -e "Done! Run \`heroku completion:gen\` if you need to regenerate this data (e.g. if you update heroku or install plugins)."
  fi
  cat "$fn"
}

_heroku_apps() {
  local fn=$(_heroku_plugin_path)/data/completion-apps.txt
  if [[ ! -f "$fn" ]]; then
    >&2 echo -e "\nLoading list of apps, this will take a few seconds."
    _heroku_touch
    heroku apps | grep -v '=' | cut -d' ' -f1 | awk 'NF' > "$fn"
    >&2 echo -e "Run \`heroku completion:apps\` when you get access to new apps."
  fi
  cat "$fn"
}

_heroku_apps_short() {
  _heroku_apps | awk '{ print "-a"$1 }'
}

_heroku_commands() {
  _heroku_data | cut -d' ' -f1
}

_heroku_main_commands() {
  _heroku_commands | grep -v ':'
}

_heroku_switches() {
  _heroku_data | grep -e "^$1 " | cut -d' ' -f2-
}

_heroku_subcommands_regex() {
  _heroku_commands | tr "\n" "|" | sed 's/|$//'
}

_heroku_remotes() {
  # This regex looks complicated but it only is due to a tab being in there, and we use the $'\t' trick
  git remote -v 2>/dev/null | sed -n 's/\(.*\)'$'\t''.*heroku\.com.*(push)/\1/p'
}

_heroku_remotes_short() {
  _heroku_remotes | awk '{ print "-r"$1 }'
}

_heroku_gitroot() {
  local path=$(git rev-parse --show-toplevel 2> /dev/null)
  [ -z "$path" ] && path="$(pwd)"
  echo "$path"
}

_heroku_rake_tasks() {
  local fn=$(_heroku_plugin_path)/data/completion-rake.txt
  local gitroot="$(_heroku_gitroot)"
  if [[ ! -f "$fn" || $(cat "$fn" | grep "$gitroot:") == "" ]]; then
    >&2 echo -e "\nLoading list of rake tasks, this will take a few seconds."
    local tasks=$(rake -s -T 2>/dev/null | awk '{ print $2 }' | tr "\n" " ")
    if [ -z "$tasks" ]; then
      >&2 echo "No rake tasks found! Are you in the correct directory?"
      return
    fi
    echo "$gitroot: $tasks" >> "$fn"
  fi
  cat "$fn" | grep "$gitroot:" | cut -d':' -f2-
}

_heroku_plugin_path() {
  dirname "${BASH_SOURCE[0]}"
}

_heroku() {
  COMPREPLY=()
  local cur prev split=false
  _get_comp_words_by_ref -n : cur prev
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
    -n|--num)
      _heroku_complete "1500"
      return 0
      ;;
    run)
      _heroku_complete "bash rails rake irb ruby node"
      return 0
      ;;
    rails)
      _heroku_complete "console"
      return 0
      ;;
    rake)
      # e.g. heroku run rake db:seed
      _heroku_complete "$(_heroku_rake_tasks)"
      __ltrim_colon_completions "$cur"
      return 0
      ;;
    ruby|node)
      # e.g. heroku run ruby scripts/fix_bad_records.rb
      pushd "$(_heroku_gitroot)" >/dev/null
      _filedir
      popd >/dev/null
      return 0
      ;;
    plugins:update|plugins:uninstall)
      local dir=$(dirname $(_heroku_plugin_path))
      _heroku_complete "$(ls "$dir")"
      return 0
      ;;
  esac

  # Specific completion for subcommand switches (incomplete)
  if [[ ${COMP_WORDS[1]} == logs ]]; then
    if [[ $prev =~ ^(-s|--source)$ ]]; then
      _heroku_complete "app heroku"
      return 0
    elif [[ $cur =~ ^(-s) ]]; then
      _heroku_complete "-sapp -sheroku"
      return 0
    fi
    if [[ $prev =~ ^(-p|--ps)$ ]]; then
      _heroku_complete "api router web worker heroku-postgres"
      return 0
    elif [[ $cur =~ ^(-p) ]]; then
      _heroku_complete "-prouter -pweb -pworker -pheroku-postgres"
      return 0
    fi
  fi

  $split && return 0

  if [[ $cur =~ ^(-a) ]]; then
    _heroku_complete "$(_heroku_apps_short)"
  elif [[ $cur =~ ^(-r) ]]; then
    _heroku_complete "$(_heroku_remotes_short)"
  elif [[ $cur =~ ^(-n) ]]; then
    _heroku_complete "-n1500"
  elif [[ $cur =~ ^($(_heroku_subcommands_regex)) ]]; then
    # compopt +o nospace
    _heroku_complete "$(_heroku_commands)"
  elif [[ (($COMP_CWORD > 1)) && ${COMP_WORDS[1]} != help ]]; then
    _heroku_complete "$(_heroku_switches "${COMP_WORDS[1]}") -a --app -r --remote"
  else
    # compopt -o nospace
    _heroku_complete "$(_heroku_main_commands)"
  fi
  __ltrim_colon_completions "$cur"
  return 0
}

# Swap this and uncomment the compopt lines above if you have compopt, e.g. on Linux.
complete -o nospace -F _heroku heroku
# complete -F _heroku heroku
