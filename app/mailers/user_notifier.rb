class UserNotifier < ApplicationMailer
    default :from => 'weatheralerts@titanhomesllc.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_current_text(weather)
    @weather = weather
    @user = ENV['CONTACTS']
    mail( :to => @user,
    :subject => 'Current Wind Alert' )
  end

  def send_forecasted_text(weather)
  	@weather = weather
  	@user = ENV['CONTACTS']
  	mail( :to => @user, :subject => 'Forecasted Wind')
  end
end