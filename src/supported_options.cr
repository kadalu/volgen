require "./helpers"

LOG_LEVELS = ["info", "error", "debug"]
ON_OFF = ["on", "off", "enable", "disable", "yes", "no"]

VolfileOptions.option_config "diagnostics.client-log-level" do |opt|
  opt.type = "client"
  opt.name = "log-level"
  opt.xlator = "debug/io-stats"
  opt.allowed_values = LOG_LEVELS
end

VolfileOptions.option_config ["diagnostics.brick-log-level", "diagnostics.storage-unit-log-level"] do |opt|
  opt.type = "storage_unit"
  opt.name = "log-level"
  opt.xlator = "debug/io-stats"
  opt.allowed_values = LOG_LEVELS
end

VolfileOptions.option_config "performance.open-behind" do |opt|
  opt.xlator = "performance/open-behind"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.write-behind" do |opt|
  opt.xlator = "performance/write-behind"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.stat-prefetch" do |opt|
  opt.xlator = "performance/md-cache"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.quick-read" do |opt|
  opt.xlator = "performance/quick-read"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.read-ahead" do |opt|
  opt.xlator = "performance/read-ahead"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "client.event-threads" do |opt|
  opt.xlator = "protocol/client"
  opt.name = "event-threads"
end

VolfileOptions.option_config "server.event-threads" do |opt|
  opt.xlator = "protocol/server"
  opt.name = "event-threads"
end

VolfileOptions.option_config "performance.strict-o-direct" do |opt|
  opt.xlator = "performance/write-behind"
  opt.name ="strict-O_DIRECT"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.io-cache" do |opt|
  opt.xlator = "performance/io-cache"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.readdir-ahead" do |opt|
  opt.xlator = "performance/readdir-ahead"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.client-io-threads" do |opt|
  opt.type = "client"
  opt.xlator = "performance/io-threads"
  opt.allowed_values = ON_OFF
end

VolfileOptions.option_config "performance.read-after-open" do |opt|
  opt.xlator = "performance/open-behind"
  opt.name ="read-after-open"
  opt.allowed_values = ON_OFF
end
