require "screenshot"
require "active_support"
require "slim"
require "mime-types"
require "fog/aws"
require "fog/local"

module ScreenshotCollector
  class Client
    def initialize(config, storage_config)
      @client = Screenshot::Client.new(config)
      @now = Time.now
      storage = Fog::Storage.new(storage_config[:fog_credentials])
      @directory = storage.directories.create(key: storage_config[:fog_directory])
    end

    def get_browsers
      @client.get_os_and_browsers.inject({}) do |data, browser|
        key = browser.slice(:device, :os, :os_version, :browser, :browser_version).select{ |k, v| v.to_s != "" }.map{ |k, v| v.to_s.gsub(/\s+/, "-").gsub(/[^a-zA-Z0-9.\-]/, "") }.join("_")
        data[key] = browser
        data
      end
    end

    def take(request)
      request_id = @client.generate_screenshots(request)
      puts "Waiting for screenshot request\##{request_id}"
      while @client.screenshots_status(request_id) != "done"
        print "."
        sleep 2
      end
      print "\n"
      puts "Complete the screenshot request\##{request_id}"
      results = @client.screenshots(request_id)

      screenshots = Hash[results.group_by { |s| "#{s[:device]}" }.map { |device, s|
        [device, s.group_by { |ss| "#{ss[:os]} #{ss[:os_version]}" }]
      }]

      locals = {
        title: "Screenshot #{@now.strftime("%Y/%h/%d %H:%M:%S")}",
        request: request,
        screenshots: screenshots
      }
      body = Slim::Template.new(File.join(__dir__, "template.slim")).render(nil, locals)

      n = SecureRandom.random_number(100)
      filename = "#{@now.strftime("%Y%m%d")}/#{@now.strftime("%H%M%S")}-#{n.to_s.rjust(3, "0")}.html"
      file = @directory.files.create(key: filename, body: body, public: true)
      file.public_url
    end
  end
end
