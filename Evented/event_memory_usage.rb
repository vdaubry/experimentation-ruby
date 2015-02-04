require 'eventmachine'
require 'open-uri'
require 'mini_magick'
require_relative 'background_job'

def download_image(url)
  path = "image.jpg"
  open(path, 'wb') do |file|
    file << open(url).read
  end
  path
end

def generate_thumbs(image_path)
  BackgroundJob.async do
    puts "generating thumb"
    sleep 1
    image = MiniMagick::Image.open(image_path) 
    image.resize "300x300"
    image.write "thumb.jpg"
  end
  .then do
    puts "Thumb generated"
  end
  .run
end

EM.run do
  #What's the impact of processing mutliple images at the same in terms of CPU and Memory
  EM.add_periodic_timer(0.25) do
    cpu = `ps -p #{Process.pid} -o %cpu,%mem | awk '{print $1}'`.scan(/[0-9]{1,2}.[0-9]{1,2}/).first
    ram = `ps -p #{Process.pid} -o %cpu,%mem | awk '{print $2}'`.scan(/[0-9]{1,2}.[0-9]{1,2}/).first
    puts "Current ressource usage : RAM=#{ram}% CPU=#{cpu}%"
  end
  
  BackgroundJob.async do
    download_image("https://dl.dropboxusercontent.com/u/995341/sample.png")
  end
  .then do |path|
    generate_thumbs(path)
  end
  .run  
end