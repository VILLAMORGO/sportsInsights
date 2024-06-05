class Api::V1::ResponsesController < ApplicationController
    def index
      @user = User.find(params[:user_id])
      @responses = @user.responses
      render json: @responses
    end
end