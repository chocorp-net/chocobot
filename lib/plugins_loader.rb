# frozen_string_literal: true

require 'rufus-scheduler'

# Loads and runs plugins
# Each plugin cosntructor takes the scheduler as only parameter
class PluginsLoader
  def stop
    @plugins.each { |p| p.stop }
  end

  private

  def initialize(bot, path = nil)
    @bot = bot
    if path
      @plugins_path = path
    else
      dirname = File.dirname(__FILE__)
      @plugins_path = "#{dirname}/plugins"
    end
    @scheduler = Rufus::Scheduler.new
    load_plugins
  end

  def load_plugins
    @plugins = []
    puts "#{@plugins_path}/*_plugin.rb"
    Dir["#{@plugins_path}/*_plugin.rb"].each do |f|
      puts "Found #{f}"
      load f
      @plugins.append Plugin.new(@scheduler, @bot)
    end
  end
end
