default_run_options[:pty] = true

# be sure to change these
set :user, 'rkamun1'
set :domain, 'chirp.touchinspiration.com'
set :application, 'chirp'

# the rest should be good
set :repository,  "git@github.com:touchinspiration/chirp.git"
set :deploy_to, "/home/#{user}/#{domain}"
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, false

server domain, :app, :web
role :db, domain, :primary => true

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test --without development"
  end
end
 
after 'deploy:update_code', 'bundler:bundle_new_release'
namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
