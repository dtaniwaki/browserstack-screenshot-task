require 'rubygems'

lib_dir = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift lib_dir

Dir[File.join(__dir__, "config/initializers/**/*.rb")].each {|f| require f }

Rake.add_rakelib "lib/tasks"
