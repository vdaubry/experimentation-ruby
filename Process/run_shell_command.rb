#!/usr/bin/env ruby
require 'fileutils'

class Base
  def self.which(command)
    location = `which #{command}`.strip
    return location=="" ? nil : location
  end
  
  def self.execute_command(*args)
    exec(args.join(" "))
  end
end

class Tor
  def initialize(tor_port, tor_control_port)
    @tor_port = tor_port
    @tor_control_port = tor_control_port
    @tor_dir = File.expand_path File.dirname(__FILE__)+"/tor"
    
    FileUtils.mkdir_p "#{@tor_dir}"
  end
  
  def run
    tor_command = Base.which("tor")
    Base.execute_command(tor_command,
        "--SocksPort #{@tor_port}",
        "--ControlPort #{@tor_control_port}",
        "--CookieAuthentication 0",
        "--HashedControlPassword \"\"",
        "--NewCircuitPeriod 60",
        "--DataDirectory #{@tor_dir}/#{@tor_port}",
        "--PidFile #{@tor_dir}/#{@tor_port}.pid",
        "--Log \"notice syslog\"",
        "--RunAsDaemon 1")
  end
end

Tor.new(9050, 50001).run