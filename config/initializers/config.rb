require "config"

env = ENV["SCREENSHOT_ENV"] || "development"
config_dir = File.expand_path("../../", __FILE__)
Config.load_and_set_settings(File.join(config_dir, "settings.yml"), File.join(config_dir, "#{env}.yml"), File.join(config_dir, "settings.local.yml"), File.join(config_dir, "#{env}.local.yml"))
