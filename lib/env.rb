# frozen_string_literal: true

class EnvironmentError < StandardError; end

# OS environment variable accessor
class Environment
  def initialize(path = '')
    @vars = {}
    begin
      file = File.open(path)
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
      raise EnvironmentError, "Unknown variable: #{identifier}"
    end
  end
end
