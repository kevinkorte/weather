class UserNotifier < ApplicationMailer
    default :from => 'kevinkorte15@gmail.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email()
    @user = 'kevin@titanhomesllc.com'
    mail( :to => @user,
    :subject => 'Thanks for signing up for our amazing app' )
  end
end
