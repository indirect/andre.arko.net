require "bundler/setup"
require "rack/jekyll"
require "rack-livereload"

require_relative "_plugins/live_reload_server"
Jekyll::LiveReloadServer.start!

use Rack::LiveReload
run Rack::Jekyll.new(auto: true, future: true)
