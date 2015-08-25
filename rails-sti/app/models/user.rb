class User < ActiveRecord::Base
  has_many :billing_adresses
  has_many :shipping_adresses
end
