require "bundler/setup"
require "rack/jekyll"

run Rack::Jekyll.new(auto: true, future: true)
