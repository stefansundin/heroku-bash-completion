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
  # prints command to put in your .bash_profile, usually:
  # source "$HOME/.heroku/plugins/heroku-bash-completion/heroku-completion.bash"
  #
  def init
    path = File.expand_path("#{__FILE__}/../../../../../heroku-completion.bash")
    puts "source \"#{path}\""
  end

  # completion:gen
  #
  # generate completion data
  #
  def gen
    clean
    %x( bash -lic _heroku_commands )
    %x( bash -lic _heroku_apps )
  end

  # completion:apps
  #
  # generate apps completion data
  #
  def apps
    File.delete("#{data_path}/completion-apps.txt") rescue nil
    %x( bash -lic _heroku_apps )
  end

  # completion:clean
  #
  # reset command, apps and rake cache
  #
  def clean
    puts "Deleting files from ~/.heroku/heroku-bash-completion/data/"
    File.delete("#{data_path}/completion.txt") rescue nil
    File.delete("#{data_path}/completion-apps.txt") rescue nil
    File.delete("#{data_path}/completion-rake.txt") rescue nil
  end

  # completion:web
  #
  # opens the website https://github.com/stefansundin/heroku-bash-completion
  #
  def web
    %x( open https://github.com/stefansundin/heroku-bash-completion )
  end

  # completion:version
  #
  # prints version of plugin (v0.2)
  #
  def version
    puts "v0.2"
  end

private

  def data_path
    File.expand_path("#{__FILE__}/../../../../../data/")
  end

end
