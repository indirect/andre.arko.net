require "bundler/setup"
require "rack/jekyll"
require "rack-livereload"

use Rack::LiveReload
run Rack::Jekyll.new(auto: true, future: true)
