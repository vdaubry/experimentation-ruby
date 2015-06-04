#!/usr/bin/env ruby

require 'vips'
include VIPS

require_relative 'vips/in_memory'
require 'byebug'

data = File.read("ressources/sample.jpg")
image = Vips::InMemory.new(filepath: "sample.jpg", data: data, thumb_size: 128)
output_data = image.shrink!
File.new('out-memory.jpg', 'w').write(output_data)