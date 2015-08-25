User.destroy_all
user = User.create!({first_name: "foo", last_name: "bar"})

BillingAdress.destroy_all
ShippingAdress.destroy_all

2.times {|i| BillingAdress.create!(user_id: user.id, street: "street billing #{i}", place: "paris", country: "france") }
2.times {|i| ShippingAdress.create!(user_id: user.id, street: "street shipping #{i}", place: "paris", country: "france") }