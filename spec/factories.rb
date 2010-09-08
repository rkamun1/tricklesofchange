# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Michael Hartl"
  user.email                 "mhartl@example.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
  user.daily_bank            "20"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :account do |account|
  account.details "Foo bar"
  account.cost "200"
  account.allotment "20"
  account.association :user
end

Factory.define :spending do |spending|
  spending.spending_date Time.now
  spending.spending_details "Foo bar"
  spending.spending_amount "5"
  spending.association :user
end


