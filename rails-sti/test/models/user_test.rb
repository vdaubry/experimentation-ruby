require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "associations" do
    user = User.create!({first_name: "foo", last_name: "bar"})
    2.times { BillingAdress.create!(user_id: user.id, street: "street billing", place: "paris", country: "france") }
    2.times { ShippingAdress.create!(user_id: user.id, street: "street shipping", place: "paris", country: "france") }
    
    assert (user.billing_adresses.count == 2)
    assert (user.shipping_adresses.count == 2)
  end
end
