class UserNotifier < ApplicationMailer
    default :from => 'weatheralerts@titanhomesllc.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_current_text(weather)
    @weather = weather
    @user = ENV['CONTACTS_WIND']
    mail( :to => @user,
    :subject => 'Current Wind Alert' )
  end

  def send_forecasted_text(weather)
  	@weather = weather
  	@user = ENV['CONTACTS_WIND']
  	mail( :to => @user, :subject => 'Forecasted Wind')
  end

  def send_alert_text(alert)
    @alert = alert
    @user = ENV['CONTACTS_ALERT']
    mail( :to => @user, :subject => @alert.weather )
  end

  def send_alert_email(alert)
    @alert = alert
    @user = ENV['CONTACTS_ALERT_EMAIL']
    mail( :to => @user, :subject => @alert.weather)
  end
end
