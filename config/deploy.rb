require 'rvm/capistrano'
require "capistrano-resque"

set :user, "deploy"
set :application, "optyn_magic"
set :scm, "git"
set :repository, "git@github.com:Optyn/Optyn-Magic.git"
set :branch, "master"
set :deploy_to, "/srv/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 3
server "54.235.166.119", :app, :web, :db, :primary => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

set :rvm_ruby_string, "ruby-1.9.3-p385@mail"
set :rvm_type, :user

namespace :deploy do
  desc 'Copy database.yml from shared to current folder'
  task :create_symlinks, :roles => :app, :except => {:no_release => true} do
    puts "Running symlinks"
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
  end

  desc "Migrating the database"
  task :migrate, :roles => :db do
    run "cd #{release_path} && bundle exec rake db:migrate --trace"
  end
end