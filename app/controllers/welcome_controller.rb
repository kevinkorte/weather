class WelcomeController < ApplicationController
    def index
       
        
        @conditions = Condition.all
    end
end
