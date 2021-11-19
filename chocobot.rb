#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'lib/bot'

# If PID file already exists, consider it is still running
pid_file = "#{File.expand_path(File.dirname(__FILE__))}/chocobot.pid"
if File.file?(pid_file)
    $stderr.puts "Chocobot is already running (PID ##{File.read(pid_file.chomp)})"
    exit 1
end

# Writing PID into a file
File.open(pid_file, 'w') { |f| f.write "#{Process.pid}" }


bot = ChocoBot.new
bot.run

# Removing PID file on exit
File.delete(pid_file)
