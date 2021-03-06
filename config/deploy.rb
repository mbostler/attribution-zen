# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'attribution-zen'
set :repo_url, 'https://github.com/mbostler/attribution-zen.git'

# require 'rvm/capistrano'
set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.2.0@attribution-zen'
# set :rvm_ruby_string, :local
# set :rvm_add_to_group, 'satori'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, "/home/satori/www/deploy/attribution-zen"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  desc "restart web server"
  task :restart_web_server do
    on roles(:web) do
      within release_path do
        execute "service thin restart"
      end      
    end
  end
  
  desc "links up .env file"
  task :link_env_file do
    on roles(:web) do
      execute "ln -s #{File.join(shared_path, '.env')} #{File.join(release_path, '.env')}"      
    end
  end
  
  after :finishing, :restart_web_server
  after :finishing, :link_env_file

end
