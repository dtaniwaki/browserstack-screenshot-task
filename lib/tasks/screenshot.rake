require "active_support"
require "screenshot_collector"
require "slack-notifier"

namespace :screenshot do
  config = { username: Settings.browserstack.username, password: Settings.browserstack.password }
  storage_config = Settings.storage.to_hash
  browsers_file_path = "./config/browsers.yml"

  desc "Update #{browsers_file_path} based on the available browsers from browserstack API"
  task :update_browsers do |t, args|
    collector = ScreenshotCollector::Client.new(config, storage_config)
    File.open(browsers_file_path, "w") do |out|
      puts "Update #{browsers_file_path}"
      YAML.dump(collector.get_browsers, out)
    end
  end

  desc "Take screenshot"
  task :take, [:url] do |t, args|
    collector = ScreenshotCollector::Client.new(config, storage_config)
    all_browsers = YAML.load_file(browsers_file_path)
    browsers = Settings.screenshot.browsers.map { |name| all_browsers[name] }.compact
    url = collector.take(
      url: args.url,
      win_res: nil, #Options : "1024x768", "1280x1024"
      mac_res: nil, #Options : "1024x768", "1280x960", "1280x1024", "1600x1200", "1920x1080"
      quality: "compressed",
      wait_time: 10,
      orientation: nil, #Options: "portrait", "landscape"
      browsers: browsers
    )
    puts "Output the results to #{url}"
    if Settings.slack.enabled
      messages = []
      messages << Slack::Notifier::LinkFormatter.format("The screenshots are available on #{url}")
      notifier = Slack::Notifier.new Settings.slack.incoming_webhook
      notifier.ping messages.join("\n")
    end
  end
end
