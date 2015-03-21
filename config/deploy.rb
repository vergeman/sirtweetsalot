# config valid only for current version of Capistrano
#lock '3.4.0'
require 'dotenv'
Dotenv.load

set :application, 'sirtweetsalot'
set :repo_url, 'git@github.com:vergeman/sirtweetsalot.git'
set :user, "ubuntu"
set :ssh_options, { :forward_agent => true }

set :delayed_job_command, "bin/delayed_job"

set :deploy_to, "~/sirtweetsalot"

#RVM
set :rvm_type, :auto                     # Defaults to: :auto
set :rvm_ruby_version, '2.2.0@sirtweetsalot'      # Defaults to: 'default'
#set :default_env, { rvm_bin_path: '~/.rvm/gems/ruby-2.2.0@sirtweetsalot/bin' }
#set :rvm_type, :user
#set :default_env, { rvm_bin_path: '~/.rvm/bin' }

set :linked_files, %w{.env}

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end


end

=begin
after 'deploy:publishing', 'deploy:restart'           
namespace :deploy do
  task :restart do
    invoke 'delayed_job:stop'
    #invoke 'delayed_job:start'
    invoke 'delayed_job:restart'    
  end                                                
end

=end
