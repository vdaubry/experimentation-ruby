require 'eventmachine'
require 'open-uri'
require 'mini_magick'

class BackgroundJob
  attr_accessor :work, :callback
  
  def self.async(&block)
    bj = BackgroundJob.new
    bj.work = block
    bj
  end
  
  def then(&block)
    @callback=block
    self
  end
  
  def run
    EM.defer(@work, @callback)
  end
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

def download_image(url)
  puts "Downloading image"
  path = "image.jpg"
  open(path, 'wb') do |file|
    file << open(url).read
  end
  puts "Image downloaded"
  path
end


EM.run do
  #Add a timer for visual feedback of blocking calls on event loop
  EM.add_periodic_timer(0.25) { puts 'tick' }
  
  BackgroundJob.async do
    download_image("https://dl.dropboxusercontent.com/u/995341/sample.png")
  end
  .then do |image|
    generate_thumbs(image)
  end
  .run
end
