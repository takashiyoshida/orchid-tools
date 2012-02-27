#!/usr/bin/env ruby

class Command
  attr_reader :cmd

  def initialize(cmd)
    @cmd = cmd
  end

  def run
    puts "Running: #{@cmd}"
    success = system(@cmd)
  end

  def pipe
    puts "Running: #{@cmd}"
    `#{@cmd}`
  end
  
  def to_s
  	str = "#{@cmd}"
  end
end

if $0 == __FILE__
end
