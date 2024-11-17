# frozen_string_literal: true
require 'io/console'

def create_super_user(email, password)
  user = User.new(email: email, password: password, password_confirmation: password)
  user.is_admin = true
  user.save!

  puts "Super user created successfully!"
end

puts "Creating super user..."

puts "Please enter the email address for the super user:"
email = gets.chomp

puts "Please enter the password for the super user:"
password = STDIN.noecho(&:gets).chomp

create_super_user(email, password)