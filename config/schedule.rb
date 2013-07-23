set :output, "/srv/apps/optyn_magic/shared/log/cron_log.log"
every 1.minute do
  rake "messages:create"
end
