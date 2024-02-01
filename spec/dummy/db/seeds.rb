if Rails.env.development?
  user = FBScraper::User.first_or_initialize(email: "admin@example.com")

  if user.new_record?
    user.assign_attributes(password: "admin123", password_confirmation: "admin123")
    user.save!
  end
end
