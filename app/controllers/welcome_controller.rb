class WelcomeController < ApplicationController
    def index
       
        
        @conditions = Condition.all.order(created_at: :desc)
    end
end
