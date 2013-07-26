require 'resque/pool/tasks'
# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
task "resque:setup" do
  # generic worker setup, e.g. Hoptoad for failed jobs
end
task "resque:pool:setup" do

end


