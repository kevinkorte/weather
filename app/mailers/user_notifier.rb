class UserNotifier < ApplicationMailer
    default :from => 'weatheralert@titanhomesllc.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(res)
    @res = res
    @user = 'kevin@titanhomesllc.com'
    mail( :to => @user,
    :subject => 'WIND ALERT' )
  end
end
