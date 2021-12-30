# frozen_string_literal: true

require 'env'

RSpec.describe Environment do
  it 'reads an existing environment variable' do
    env = described_class.new
    expect { env.get 'PWD' }.not_to raise_error
  end

  # Make sure a minimum environment file exists
  dir_name = __FILE__[0..-__FILE__.split('/')[-1].length - 1].to_s
  begin
    File.open("#{dir_name}/../chocobot.env")
  rescue Errno::ENOENT
    file = File.open("#{dir_name}/../chocobot.env", 'w') do |_f|
      file.write('DISCORD_OWNER_ID=example')
    end
  end

  it 'reads a variable from chocobot.env' do
    env = described_class.new
    expect { env.get 'DISCORD_OWNER_ID' }.not_to raise_error
  end
end
