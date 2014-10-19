require "heroku/command/base"

# amazing bash completion
# MIT License, same as heroku-cli

class Heroku::Command::Completion < Heroku::Command::Base

  # completion
  #
  # gives your bash amazing completion powers
  # https://github.com/stefansundin/heroku-bash-completion
  #
  def index
    puts "https://github.com/stefansundin/heroku-bash-completion"
  end

  # completion:init
  #
  # prints path to the file that initializes the bash completion
  # put this in your .bash_profile:
  # source "$(heroku completion:init)"
  #
  def init
    puts File.expand_path("#{__FILE__}/../../../../../heroku-completion.bash")
  end

  # completion:version
  #
  # prints version of plugin (v0.1)
  #
  def version
    puts "v0.1"
  end

  # completion:clean
  #
  # reset command, apps and rake cache
  #
  def clean
    puts "Deleting ~/.heroku/{completion,completion-apps,completion-rake}"
    File.delete(File.expand_path("~/.heroku/completion")) rescue nil
    File.delete(File.expand_path("~/.heroku/completion-apps")) rescue nil
    File.delete(File.expand_path("~/.heroku/completion-rake")) rescue nil
  end

end
