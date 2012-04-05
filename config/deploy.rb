set :application, "socialactions"
default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git://github.com/socialactions/socialactions.git"  # Your clone URL
set :scm, "git"
set :scm_verbose, true
set :branch, "master"

set :rvm_ruby_string, 'ree'     
require "rvm/capistrano"   
set :rvm_type, :system
set :rvm_bin_path, "/usr/local/bin"

set :deploy_to, "/var/www/socialactions/"
set :user, "socialactions"  # The server's user for deploys
set :use_sudo, false
set :rake, "/usr/local/rvm/bin/rake"

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

role :web, "search.socialactions.com"                          # Your HTTP server, Apache/etc
role :app, "search.socialactions.com"                          # This may be the same as your `Web` server
role :db,  "search.socialactions.com", :primary => true # This is where Rails migrations will run

namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "rm -Rf #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/"

    run "rm -Rf #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/"

    run "rm -Rf #{release_path}/solr"
    run "ln -nfs #{shared_path}/solr #{release_path}/"
  end  

  desc "Restart Application"
  task :restart, :roles => :app do
    run "cd #{release_path} && thin restart -O -C config/thin.yml"
  end


  desc "Restart SOLR"
  task :restart_solr, :roles => :app do
    run "cd #{release_path}; RAILS_ENV=production #{rake} sunspot:solr:stop"
    run "cd #{release_path}; RAILS_ENV=production #{rake} sunspot:solr:start"
  end
end

after 'deploy:symlink', 'deploy:symlink_shared'
