def prompt(output, noecho = false)
  output = "\e[32m#{output}\e[0m"
  print("#{output}\n")
  noecho ? STDIN.noecho(&:gets).strip : STDIN.gets.strip
end

def get_user_input
  details = {}
  details[:email] = prompt 'Enter an email address for the user:'
  details[:name] = prompt 'Enter a name for the user:'
  details[:phone_number] = prompt 'Enter a phone number for the user:'
  details
end

def get_password
  password = prompt 'Enter a password for the user:', true
  password_confirm = prompt 'Please confirm the user:', true
  if password == password_confirm
    return password
  else
    print "\e[31mYour passwords do not match, please try again\e[0m\n\n"
    sleep(0.5)
    get_password
  end
end

def create_user
  details = get_user_input
  password = get_password
  ActiveRecord::Base.logger.silence do
    s = Supplier.create(details)
    s.admin = true
    s.password = password
    s.password_confirmation = password
    if s.save
      print "\e[32mUser #{details[:email]} has been created! You can log in at http://localhost:3000/admin\e[0m\n"
    else
      print "\e[31mWe had a problem creating the user . The errors were as follows:\e[0m\n"
      s.errors.full_messages.each do |e|
        print "\e[31m#{e}\e[0m\n"
      end
      print "\e[31mPlease try again\e[0m\n\n"
      create_user
    end
  end
end

namespace :admin do
  task :create => :environment do
    create_user
  end
end
