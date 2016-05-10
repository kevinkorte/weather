class WelcomeController < ApplicationController
    def index
       
        
        @conditions = Condition.all.order(created_at: :desc)
        @last_condition = Condition.last
    end
end
