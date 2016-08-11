if ENV['NEW_RELIC_LICENSE_KEY']
  require 'newrelic_rpm'
  NewRelic::Agent.manual_start
end

require_relative './queue_io.rb'
require_relative './upload.rb'
require_relative './app.rb'

$stdout.sync = true
queue_io = QueueIO.new
upload = Upload.new(queue_io)
upload.start

if ENV['HTTP_USER'].to_s == '' && ENV['HTTP_PASSWORD'].to_s == ''
  # skip
else
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ENV['HTTP_USER'], ENV['HTTP_PASSWORD']]
  end
end

run App.new(queue_io)
