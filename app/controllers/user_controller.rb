class UserController < ApplicationController
  def show
  	@user = current_user
  	@maps = @user.maps.all
  	@map_count = @maps.length
  end
end
