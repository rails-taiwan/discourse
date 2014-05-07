# -*- encoding : utf-8 -*-

require "./config/boot"
require "bundler/capistrano"
require "rvm/capistrano"
require 'capistrano/sidekiq'

require 'capistrano-unicorn'

default_environment["PATH"] = "/opt/ruby/bin:/usr/local/bin:/usr/bin:/bin"

set :application, "discourse"
set :repository,  "git@github.com:rails-taiwan/#{application}.git"
set :deploy_to, "/home/apps/community-tw"

set :branch, "production"
set :scm, :git

set :user, "apps"
set :group, "apps"


set :runner, "apps"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :use_sudo, false
set :rvm_ruby_string, '2.1.0'



role :web, "106.186.125.54"                          # Your HTTP server, Apache/etc
role :app, "106.186.125.54"                         # This may be the same as your `Web` server
role :db,  "106.186.125.54"   , :primary => true # This is where Rails migrations will run

set :deploy_env, "production"
set :rails_env, "production"
set :scm_verbose, true
set :use_sudo, false



namespace :deploy do

  desc "Restart passenger process"
  task :restart, :roles => [:web], :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


namespace :my_tasks do
  task :symlink, :roles => [:web] do
    run "mkdir -p #{deploy_to}/shared/log"
    run "mkdir -p #{deploy_to}/shared/pids"
    
    symlink_hash = {
      "#{shared_path}/config/discourse_defaults.conf"   => "#{release_path}/config/discourse_defaults.conf",
      "#{shared_path}/config/s3.yml"   => "#{release_path}/config/s3.yml",
      "#{shared_path}/uploads"              => "#{release_path}/public/uploads",
    }

    symlink_hash.each do |source, target|
      run "ln -sf #{source} #{target}"
    end
  end

end



namespace :remote_rake do
  desc "Run a task on remote servers, ex: cap staging rake:invoke task=cache:clear"
  task :invoke do
    run "cd #{deploy_to}/current; RAILS_ENV=#{rails_env} bundle exec rake #{ENV['task']}"
  end
end

after "deploy:finalize_update", "my_tasks:symlink"
after 'deploy:restart', 'unicorn:reload'
after 'deploy:restart', 'unicorn:restart'
