FactoryBot.define do
  factory :user do
    # attributes for user
    email { 'testuser@example.com' }
    password { 'password' }
    admin { true }
  end
end
