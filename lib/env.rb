# frozen_string_literal: true

class EnvironmentError < StandardError; end

# OS environment variable accessor
class Environment
  def initialize
    @vars = {}
    dir_name = __FILE__[0..-__FILE__.split('/')[-1].length - 1].to_s
    begin
      file = File.open("#{dir_name}/../chocobot.env")
      file.each do |line|
        unless line.start_with? '#'
          k, v = line.split('=')
          @vars[k] = v.gsub('"', '').chop
        end
      end
    rescue Errno::ENOENT
      # Environment file doesn't exist ; skipping
    end
  end

  def get(identifier)
    if @vars.keys.include?(identifier)
      @vars[identifier]
    elsif ENV.keys.include?(identifier)
      ENV[identifier]
    else
      throw EnvironmentError.new "Unknown variable: #{identifier}"
    end
  end
end
