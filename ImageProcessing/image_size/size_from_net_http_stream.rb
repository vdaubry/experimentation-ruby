require "image_size"
require 'net/http'

uri = URI("https://upload.wikimedia.org/wikipedia/commons/6/62/Potassium-dichromate-sample.jpg")

buffer = StringIO.new
size = nil
Net::HTTP.get_response(uri) do |res|

  res.read_body do |chunk|
    buffer.write(chunk)

    if size.nil?
      begin
        size = ImageSize.new(buffer).size
        p "Image size is : #{size}"
      rescue ImageSize::FormatError => e
        puts "not enough bytes to get size : #{buffer.size} bytes"
      end
    end
  end
end

p "done"