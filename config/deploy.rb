require 'rvm/capistrano'
require 'bundler/capistrano'

set :user, "deploy"
set :application, "optyn_magic"
set :scm, "git"
set :repository, "git@github.com:Optyn/Optyn-Magic.git"
set :branch, "master"
set :deploy_to, "/srv/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 3
set :rails_env, 'production'
server "54.235.166.119", :app, :web, :db, :primary => true

#role :resque_worker, "optyn_magic"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

set :rvm_ruby_string, "ruby-1.9.3-p385@mail"
set :rvm_type, :user
set :whenever_command, "whenever"
require "whenever/capistrano"

after 'deploy:update_code', 'deploy:create_symlinks'
after 'deploy:update_code', 'deploy:migrate'
after "deploy", "deploy:cleanup"
after "deploy", "resque:restart"
after "deploy", "rvm:create_rvmrc"
after "rvm:create_rvmrc", "rvm:trust_rvmrc"


namespace :deploy do
  desc 'Copy database.yml from shared to current folder'
  task :create_symlinks, :roles => :app, :except => {:no_release => true} do
    puts "Running symlinks"
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml"
    run "ln -s #{shared_path}/config/app_credentials.yml #{current_release}/config/app_credentials.yml"
  end

  desc "Migrating the database"
  task :migrate, :roles => :db do
    run "cd #{release_path} && rake db:migrate --trace"
  end
end

namespace :resque do
  task :start, roles => :app do
    run "cd #{release_path} && QUEUE=email_processor BACKGROUND=yes rake resque:work"
  end

  task :stop, roles => :app do
    run "pkill -9 -f email_processor" rescue nil
  end

  task :restart, roles => :app do
    stop
    start
  end
end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end

  task :create_rvmrc do
    run "echo 'rvm use #{rvm_ruby_string}' > #{release_path}/.rvmrc"
  end
end