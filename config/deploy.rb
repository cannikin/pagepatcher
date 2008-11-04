set :application, 'pagepatcher'

default_run_options[:pty] = true
set :repository,  "git@github.com:cannikin/pagepatcher.git"
set :scm, "git"
set :scm_passphrase, "" #This is your custom users password
set :branch, "master"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "borges.mojombo.com"
role :web, "borges.mojombo.com"
role :db,  "borges.mojombo.com", :primary => true

set :user, "rcameron"
set :runner, "rcameron"