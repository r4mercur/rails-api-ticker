class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      # here set the user to the session
      session[:user_id] = user.id
      render json: { status: 'Logged in successfully', user: user }
    else
      # The user is not authenticated
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { status: 'Logged out successfully' }
  end
end
