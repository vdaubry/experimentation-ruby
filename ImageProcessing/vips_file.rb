#!/usr/bin/env ruby

require_relative 'vips/file'
require 'byebug'

image = Vips::File.new(filepath: "ressources/sample.jpg", thumb_size: 128, thumbpath: "out-file.jpg")
image.shrink!