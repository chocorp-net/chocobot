#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'lib/bot'
require_relative 'lib/query'
require_relative 'lib/env/env'

env = Environment.new
bot = ChocoBot.new env
qforge = QueryForge.new env

bot.ready do
  bot.pm('⚙️ I\'m up!')
end

bot.run(true)

begin
  loop do
    # Nagios
    # TODO
    # 3d printer is done
    bot.pm(qforge.check_printing)
    # Root-Me
    bot.pm(qforge.check_rootme)
    sleep env.get('SLEEP_TIME').to_i
  end
rescue Interrupt
  p 'Exiting'
ensure
  bot.pm('💤 Going down!')
  bot.stop
end
