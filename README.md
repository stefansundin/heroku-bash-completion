# Heroku bash completion

This lets you use tab to autocomplete your `heroku` commands. Instant bliss. :sparkles: :sparkles: :sparkles:

The plugin generates the list from the heroku help commands, so it should stay up to date with new commands. Your app names and git remotes are also autocompleted.

**Only tested on Mac.**


### Prerequisites
Install `bash-completion` and add it to your `.bash_profile` before you install this.

```bash
brew install bash-completion
```


### Install

```bash
heroku plugins:install git://github.com/stefansundin/heroku-bash-completion.git
```

Run `heroku completion:init` to get the command to put in `.bash_profile`, usually:

```bash
source "$HOME/.heroku/plugins/heroku-bash-completion/heroku-completion.bash"
```

Open a new terminal for the completion to take effect, or run the `source` command directly. The first time you use it, it will generate a list of commands that it caches in your `~/.heroku` directory. The first time you tab `--app` or `-a`, it will fetch a list of your apps. You can generate new lists by running `heroku completion:gen`. Rake tasks are also cached, e.g. `heroku run rake ...`. Heroku plugins are also completed, but not cached anywhere.

When you install new plugins or upgrade to a new version of the heroku toolbelt, run `heroku completion:gen` to update the cached list of commands. You can run `heroku completion:apps` to only generate a new list of apps.

It might be convenient to set `heroku completion:apps` to run as a cron job to periodically update the list, or you can have it run when you login.


### Usage

```bash
heroku completion
heroku completion:init
heroku completion:gen
heroku completion:apps
heroku completion:clean
heroku completion:version
```


### Update

```bash
heroku plugins:update heroku-bash-completion
```


### Uninstall

```bash
heroku completion:clean
heroku plugins:uninstall heroku-bash-completion
```

Also remove the line you added to `.bash_profile`.


# What's not autocompleted
- `heroku orgs`.
- `heroku certs -e` endpoints.
- `heroku addons`.
- Shortcuts such as `login`, `logout`, `join`, etc.


# Changelog

[![RSS](https://stefansundin.github.io/img/feed.png) Release feed](https://github.com/stefansundin/heroku-bash-completion/releases.atom)

**0.2** - 2014-10-23 - [diff](https://github.com/stefansundin/heroku-bash-completion/compare/v0.1...v0.2):
- Fixed some subcommands not being included.
- Added support for switches.
- Moved temp files to plugin directory.

**0.1** - 2014-10-18 - [diff](https://github.com/stefansundin/heroku-bash-completion/compare/4db85e...v0.1):
- First release.
