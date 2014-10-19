# Heroku bash completion

This lets you use tab to autocomplete your `heroku` commands. Instant bliss. :sparkles: :sparkles: :sparkles:

The plugin generates the list from the heroku help commands, so it should stay up to date with new commands. Your app names and git remotes are also autocompleted.

**Only tested on Mac.**


### Prerequisites:
Install `bash-completion` and add it to your `.bash_profile` before you install this.

```bash
brew install bash-completion
```


### Installation:

```bash
heroku plugins:install git://github.com/stefansundin/heroku-bash-completion.git
```

Edit your `.bash_profile` and add:

```bash
source "$(heroku completion:init)"
```


### Usage

```bash
heroku completion
heroku completion:clean
heroku completion:version
```

When you install new plugins or upgrade to a new version of the heroku toolbelt, run `bash completion:clean` to regenerate the list of commands.


### Updating

```bash
heroku plugins:update heroku-bash-completion
```


### Uninstalling

```bash
heroku plugins:uninstall heroku-bash-completion
rm ~/.heroku/completion*
```


# Changelog

[![RSS](https://stefansundin.github.io/img/feed.png) Release feed](https://github.com/stefansundin/heroku-bash-completion/releases.atom)

**0.1** - 2014-10-18 - [diff](https://github.com/stefansundin/heroku-bash-completion/compare/4db85e...v0.1):
- First release.
