require "log_decorator"

def log_init
  require "logger"

  log = Logger.new(STDERR)
  log.formatter = lambda { |_severity, _datetime, _progname, msg| "#{msg}\n" }
  log.level = case ENV['LOG_LEVEL']
              when 'ERROR' then Logger::ERROR
              when 'WARN'  then Logger::WARN
              when 'INFO'  then Logger::INFO
              when 'DEBUG' then Logger::DEBUG
              else              Logger::OFF
              end
  LogDecorator.logger = log
end

log_init

require "virt_disk"
