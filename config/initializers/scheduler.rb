scheduler = Rufus::Scheduler.new

scheduler.every '23m' do
    res = HTTParty.get(ENV['CURRENT_WEATHER_API'])
    if res['current_observation']['wind_mph'] >= 10
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
        condition = Condition.where(forecast: "Current", sent: "True").last
        if condition.present?
            last_sent = condition.created_at
            adjusted_time = last_sent + 6.hour
            if adjusted_time < Time.now.utc
                #night is today's date at 10pm UTC time
                night = Time.new(Date.today.year, Date.today.month, Date.today.day, 22,0,0).utc
                #morning is today's date at 6am UTC time
                morning = Time.new(Date.today.year, Date.today.month, Date.today.day, 6,0,0).utc
                if Time.now.utc > morning && Time.now.utc < night
                    UserNotifier.send_current_text(weather).deliver_now
                    c = Condition.where(forecast: "Current").last
                    c.update(sent: "True")
                end
            end
        else
            UserNotifier.send_current_text(weather).deliver_now
            c = Condition.where(forecast: "Current").last
            c.update(sent: "True")
        end
    else
        puts "Current winds are not fast enough"
        puts Time.now
    end
end

scheduler.every '33m' do
    res = HTTParty.get(ENV['FORECASTED_WEATHER_API'])
    weather = res['hourly_forecast'].select{|weather| weather['wspd']['english'].to_i >= 10}.first
    if weather.present?
        last_forecast = Condition.where(forecast: "Forecasted").last
        if last_forecast.present?
            current_weather_string = "Forecasted " + weather['wdir']['dir'] + " winds blowing " + weather['wspd']['english'] + " mph at " + weather['FCTTIME']['weekday_name'] + " " + weather['FCTTIME']['pretty']
            past_weather_string = last_forecast.wind_string
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
                    end
                end
            else
                puts "The weather forecast hasn't changed"
                puts Time.now
            end
        else
            UserNotifier.send_forecasted_text(@weather).deliver_now
            c = Condition.where(forecast: "Forecasted").last
            c.update(sent: "True")
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
