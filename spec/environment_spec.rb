# frozen_string_literal: true

require 'env'

RSpec.describe Environment do
  it 'reads an existing environment variable' do
    env = described_class.new
    expect { env.get 'PWD' }.not_to raise_error
  end

  it 'reads a variable from chocobot.env' do
    dir_name = __FILE__[0..-__FILE__.split('/')[-1].length - 1].to_s
    env = described_class.new "#{dir_name}/../chocobot.env"
    expect { env.get 'DISCORD_OWNER_ID' }.not_to raise_error
  end

  it 'tries to get an unknown variable' do
    env = described_class.new
    expect { env.get 'DO_NOT_EXIST' }.to raise_error EnvironmentError
  end
end
