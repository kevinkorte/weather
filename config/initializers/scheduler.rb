scheduler = Rufus::Scheduler.new

scheduler.every '7m' do #23m
    res = HTTParty.get(ENV['CURRENT_WEATHER_API'])
    if res['current_observation']['wind_mph'] >= 10
        last_saved_condition = Condition.where(forecast: "Current").last
        last_sent_condition = Condition.where(forecast: "Current", sent: "True").last
        if last_saved_condition.present? && last_sent_condition.present?
            last_saved = last_saved_condition.created_at
            last_sent = last_sent_condition.created_at
            adjusted_time = last_sent + 6.hour # 6.hour
            if last_saved + 49.minutes < Time.now.utc || adjusted_time < Time.now.utc #4.hour
                puts "Haven't saved, or sent an alert lately"
                if adjusted_time < Time.now.utc
                    puts "haven't sent an email lately"
                    #night is today's date at 10pm UTC time
                    night = Time.new(Date.today.year, Date.today.month, Date.today.day, 22,0,0).utc
                    #morning is today's date at 6am UTC time
                    morning = Time.new(Date.today.year, Date.today.month, Date.today.day, 6,0,0).utc
                    if Time.now.utc > morning && Time.now.utc < night
                        puts "it's a good time"
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
                            observation_time: res['current_observation']['observation_time'],
                            sent: "False",
                            forecast: "Current",
                            day_marker: "False",
                            isEmpty: "False"
                        )
                        UserNotifier.send_current_text(weather).deliver_now
                        c = Condition.where(forecast: "Current").last
                        c.update(sent: "True")
                    end
                else
                    Condition.create(
                        weather: res['current_observation']['weather'],
                        wind_string: res['current_observation']['wind_string'],
                        wind_dir: res['current_observation']['wind_dir'],
                        wind_mph: res['current_observation']['wind_mph'],
                        wind_gust_mph: res['current_observation']['wind_gust_mph'],
                        temp_f: res['current_observation']['temp_f'],
                        feelslike_f: res['current_observation']['feelslike_f'],
                        precip_today_in: res['current_observation']['precip_today_in'],
                        icon_url: res['current_observation']['icon_url'],
                        observation_time: res['current_observation']['observation_time'],
                        sent: "False",
                        forecast: "Current",
                        day_marker: "False",
                        isEmpty: "False"
                    )
                    puts "created an event, but did not send an email"
                end

            else
                puts "no need to save or alert on this event"
            end
        else
          Condition.create(
              weather: res['current_observation']['weather'],
              wind_string: res['current_observation']['wind_string'],
              wind_dir: res['current_observation']['wind_dir'],
              wind_mph: res['current_observation']['wind_mph'],
              wind_gust_mph: res['current_observation']['wind_gust_mph'],
              temp_f: res['current_observation']['temp_f'],
              feelslike_f: res['current_observation']['feelslike_f'],
              precip_today_in: res['current_observation']['precip_today_in'],
              icon_url: res['current_observation']['icon_url'],
              observation_time: res['current_observation']['observation_time'],
              sent: "False",
              forecast: "Current",
              day_marker: "False",
              isEmpty: "False"
          )
        end
    else
        puts "Current winds are not fast enough"
        puts Time.now
    end
end

scheduler.every '51m' do
    res = HTTParty.get(ENV['FORECASTED_WEATHER_API'])
    weather = res['hourly_forecast'].select{|weather| weather['wspd']['english'].to_i >= 10}.first
    if weather.present?
        last_forecast = Condition.where(forecast: "Forecasted").last
        #conditions = Condition.where(created_at: (Time.now.midnight)..Time.now.end_of_day)
        if last_forecast.present?
            current_weather_string = "Forecasted " + weather['wdir']['dir'] + " winds blowing " + weather['wspd']['english'] + " mph at " + weather['FCTTIME']['weekday_name'] + " " + weather['FCTTIME']['pretty']
            past_weather_string = last_forecast.wind_string
            puts past_weather_string
            puts last_forecast.wind_string
            #if check_forecast(conditions, current_weather_string)
                if current_weather_string != past_weather_string
                    puts "The Weather forecast is different! I'm saving this one."
                    puts Time.now
                    @weather = Condition.create(
                                weather: weather['condition'],
                                wind_string: "Forecasted " + weather['wdir']['dir'] + " winds blowing " + weather['wspd']['english'] + " mph at " + weather['FCTTIME']['weekday_name'] + " " + weather['FCTTIME']['pretty'],
                                wind_dir: weather['wdir']['dir'],
                                wind_mph: weather['wspd']['english'],
                                wind_gust_mph: "Unavailable",
                                temp_f: weather['temp']['english'],
                                feelslike_f: weather['feelslike']['english'],
                                precip_today_in: "Unavailable",
                                icon_url: weather['icon_url'],
                                observation_time: weather['FCTTIME']['pretty'],
                                sent: "False",
                                forecast: "Forecasted",
                                day_marker: "False",
                                isEmpty: "False"
                    )
                    condition = Condition.where(forecast: "Forecasted", sent: "True").last
                    last_sent = condition.created_at
                    if last_sent.present?
                      adjusted_time = last_sent + 6.hour
                      if adjusted_time < Time.now.utc
                        #night is today's date at 10pm UTC time
                        night = Time.new(Date.today.year, Date.today.month, Date.today.day, 22,0,0).utc
                        #morning is today's date at 6am UTC time
                        morning = Time.new(Date.today.year, Date.today.month, Date.today.day, 6,0,0).utc
                        if Time.now.utc > morning && Time.now.utc < night
                            UserNotifier.send_forecasted_text(@weather).deliver_now
                            c = Condition.where(forecast: "Forecasted").last
                            c.update(sent: "True")
                        end #if it's during the day
                      end # if we haven't sent one in awhile
                    else
                      night = Time.new(Date.today.year, Date.today.month, Date.today.day, 22,0,0).utc
                      #morning is today's date at 6am UTC time
                      morning = Time.new(Date.today.year, Date.today.month, Date.today.day, 6,0,0).utc
                      if Time.now.utc > morning && Time.now.utc < night
                          UserNotifier.send_forecasted_text(@weather).deliver_now
                          c = Condition.where(forecast: "Forecasted").last
                          c.update(sent: "True")
                      end #if it's during the day
                    end
                else # if the weather hasn't changed
                    puts "The weather forecast hasn't changed"
                    puts Time.now
                end
            #end
        else
          @weather = Condition.create(
                      weather: weather['condition'],
                      wind_string: "Forecasted " + weather['wdir']['dir'] + " winds blowing " + weather['wspd']['english'] + " mph at " + weather['FCTTIME']['weekday_name'] + " " + weather['FCTTIME']['pretty'],
                      wind_dir: weather['wdir']['dir'],
                      wind_mph: weather['wspd']['english'],
                      wind_gust_mph: "Unavailable",
                      temp_f: weather['temp']['english'],
                      feelslike_f: weather['feelslike']['english'],
                      precip_today_in: "Unavailable",
                      icon_url: weather['icon_url'],
                      observation_time: weather['FCTTIME']['pretty'],
                      sent: "False",
                      forecast: "Forecasted",
                      day_marker: "False",
                      isEmpty: "False"
          )
        end
    end #ends if we have something
end #ends scheduler

scheduler.every '179m' do
  res = HTTParty.get(ENV['ALERT_WEATHER_API']);
  if res['response']['features']['alerts'] >= 1
    last_saved_alert = Condition.where(forecast: "Alert").last
    last_sent_alert = Condition.where(forecast: "Alert", sent: "True").last
    if last_saved_alert.present? && last_sent_alert.present?
      last_saved_alert_time = last_saved_alert.created_at
      last_sent_alert_time = last_sent_alert.created_at
      alert_adjusted_time = last_sent_alert_time + 6.hours
      if alert_adjusted_time < Time.now.utc
        puts "Haven't sent an email lately"
        night = Time.new(Date.today.year, Date.today.month, Date.today.day, 22,0,0).utc
        morning = Time.new(Date.today.year, Date.today.month, Date.today.day, 6,0,0).utc
        if Time.now.utc > morning && Time.now.utc < night
          puts "it's a good time to alert"
          @alert = Condition.create(
            weather: res['alerts'][0]['description'],
            alert_message: res['alerts'][0]['message'],
            alert_start_date: res['alerts'][0]['date'],
            alert_expire_date: res['alerts'][0]['expires'],
            sent: "False",
            forecast: "Alert",
            day_marker: "False",
            isEmpty: "False"
          )
          puts 'sending email'
          UserNotifier.send_alert_text(@alert).deliver_now
          a = Condition.where(forecast: "Alert").last
          a.update(sent: "True")
          UserNotifier.send_alert_email(@alert).deliver_now
        end
      else
        @alert = Condition.create(
          weather: res['alerts'][0]['description'],
          alert_message: res['alerts'][0]['message'],
          alert_start_date: res['alerts'][0]['date'],
          alert_expire_date: res['alerts'][0]['expires'],
          sent: "False",
          forecast: "Alert",
          day_marker: "False",
          isEmpty: "False"
        )
        puts "Created an alert but did not save"
      end
    else
      @alert = Condition.create(
        weather: res['alerts'][0]['description'],
        alert_message: res['alerts'][0]['message'],
        alert_start_date: res['alerts'][0]['date'],
        alert_expire_date: res['alerts'][0]['expires'],
        sent: "False",
        forecast: "Alert",
        day_marker: "False",
        isEmpty: "False"
      )
      puts 'sending email'
      UserNotifier.send_alert_text(@alert).deliver_now
      a = Condition.where(forecast: "Alert").last
      a.update(sent: "True")
      UserNotifier.send_alert_email(@alert).deliver_now
      puts "Creating a first Event of this type"
    end
  end
end

scheduler.cron '00 00 * * *' do
    condition = Condition.where(created_at: (Time.now.midnight - 1.day)..Time.now.end_of_day - 1.day).last
    if condition.present?
        condition.update(day_marker: "True")
    else
        Condition.create(
                day_marker: "True",
                isEmpty: "True",
                created_at: Time.now.utc.noon.yesterday
            )
    end
end

# def check_forecast(conditions, current_string)
#     condition.each do |condition, current_string|
#         case condition
#         when condition == current_string
#             false
#         when condition != current_string
#             true
#         end
#     end
# end
