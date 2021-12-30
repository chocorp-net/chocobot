require 'env'
require 'os'

RSpec.describe Environment, "#get" do
  it 'reads an existing environment variable' do
    env = Environment.new
    if OS.windows?
      key = 'WINDIR'
    elsif OS.posix?
      key = 'PWD'
    else
      raise Exception.new "Unknown OS: \n#{OS.report}"
    end
    expect { env.get key }.not_to raise_error
  end
  it 'reads a variable from chocobot.env' do
    dir_name = __FILE__[0..-__FILE__.split('/')[-1].length - 1].to_s
    begin
      File.open("#{dir_name}/../chocobot.env")
    rescue Errno::ENOENT
      file = File.open("#{dir_name}/../chocobot.env", 'w') { |f|
        file.write('DISCORD_OWNER_ID=example')
      }
    end
    env = Environment.new
    expect { env.get 'DISCORD_OWNER_ID' }.not_to raise_error
  end
end