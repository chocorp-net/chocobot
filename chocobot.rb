#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'config'
require_relative 'lib/bot'

# logger = Logger.new($stdout)

# If PID file already exists, consider it is still running
pid_file = "#{__dir__}/chocobot.pid"
if File.file?(pid_file)
  warn "Chocobot is already running (PID ##{File.read(pid_file.chomp)})"
  exit 1
end

# Writing PID into a file
File.write(pid_file, Process.pid.to_s)

begin
  bot = ChocoBot.new
  bot.run
rescue StandardError => e
  raise e
ensure
  # Removing PID file on exit
  File.delete(pid_file)
end
