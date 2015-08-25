require "openssl"

#Securerandom.uuid
def secret
  "4d405f34-439c-4eea-ab2e-49cc9e671136"
end

#OpenSSL::Cipher::AES.new(256, :CBC).random_iv
def iv
  "\x85%p\xF1G9\x025\x99;\x88\xA3\xBBl\xB4\xE8"
end

def decrypt(encrypted_data, key)
  cipher = OpenSSL::Cipher::AES.new(256, :CBC)
  cipher.decrypt
  cipher.key = key
  cipher.iv = iv
  cipher.update(encrypted_data) + cipher.final
end

def encrypt(data, key)
  cipher = OpenSSL::Cipher::AES.new(256, :CBC)
  cipher.encrypt
  cipher.key = key
  cipher.iv = iv
  cipher.update(data) + cipher.final
end

data = "Very, very confidential data"
puts "original data : #{data}"
crypted_data = encrypt(data, secret)
puts "crypted data : #{crypted_data}"
decrypted_data = decrypt(crypted_data, secret)
puts "decrypted data : #{decrypted_data}"
raise StandardError unless decrypted_data == data
