set :output, "/srv/apps/optyn_magic/shared/log/cron_log.log"
every 5.minutes do
  rake "messages:create"
end
