class UserController < ApplicationController
  def show
  	if !current_user
      redirect_to root_path
  	else
  		@user = current_user
  		@maps = @user.maps.all
  		@map_count = @maps.length
    end

  	
  end
end
