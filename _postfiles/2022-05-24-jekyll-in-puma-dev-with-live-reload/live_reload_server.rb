require "jekyll/commands/serve"
require "jekyll/commands/serve/live_reload_reactor"

module Jekyll
  class LiveReloadServer
    class << self

      def start!
        opts = {
          "host" => "0.0.0.0",
          "livereload_port" => 35_729
        }

        Jekyll::Hooks.register(:site, :post_render) do |site|
          regenerator = Jekyll::Regenerator.new(site)
          @changed_pages = site.pages.select do |p|
            regenerator.regenerate?(p)
          end
        end

        @reload_reactor = Jekyll::Commands::Serve::LiveReloadReactor.new

        # A note on ignoring files: LiveReload errs on the side of reloading when it
        # comes to the message it gets.  If, for example, a page is ignored but a CSS
        # file linked in the page isn't, the page will still be reloaded if the CSS
        # file is contained in the message sent to LiveReload.  Additionally, the
        # path matching is very loose so that a message to reload "/" will always
        # lead the page to reload since every page starts with "/".
        Jekyll::Hooks.register(:site, :post_write) do
          if @changed_pages && @reload_reactor && @reload_reactor.running?
            ignore, @changed_pages = @changed_pages.partition do |p|
              Array(opts["livereload_ignore"]).any? do |filter|
                File.fnmatch(filter, Jekyll.sanitized_path(p.relative_path))
              end
            end
            Jekyll.logger.debug "LiveReload:", "Ignoring #{ignore.map(&:relative_path)}"
            @reload_reactor.reload(@changed_pages)
          end
          @changed_pages = nil
        end

        begin
          @reload_reactor.start(opts)
          @reload_reactor.thread.report_on_exception = false
          @reload_reactor&.started_event&.wait
        rescue => e
          puts "Could not start livereload server: #{e.message}"
        end
      end

      def reactor
        @reload_reactor
      end

    end
  end
end
