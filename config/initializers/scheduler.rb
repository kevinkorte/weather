
    
    #sendgrid = SendGrid::Client.new(api_key: ENV['SENDGRID_KEY'])
    scheduler = Rufus::Scheduler.new
    
    
    scheduler.every '5m' do
        res = HTTParty.get(ENV['WEATHER_API'])
            weather = Condition.create(
                weather: res['current_observation']['weather'],
                wind_string: res['current_observation']['wind_string'],
                wind_dir: res['current_observation']['wind_dir'],
                wind_mph: res['current_observation']['wind_mph'],
                wind_gust_mph: res['current_observation']['wind_gust_mph'],
                temp_f: res['current_observation']['temp_f'],
                feelslike_f: res['current_observation']['feelslike_f'],
                precip_today_in: res['current_observation']['precip_today_in'],
                icon_url: res['current_observation']['icon_url'],
                observation_time: res['current_observation']['observation_time']
            )
            UserNotifier.send_signup_email.deliver_now
            # mail = SendGrid::Mail.new do |m|
            #     m.to = 'kevin@titanhomesllc.com'
            #     m.from = 'kevinkorte15@gmail.com'
            #     m.subject = 'Current wind speed is ' + res['current_observation']['wind_mph']
            #     m.text = 'Current wind is ' + res['current_observation']['wind_string'] + ' observed at ' + res['current_observation']['observation_time']
            # end
            # sendgrid.send(mail)
        #end
    end
