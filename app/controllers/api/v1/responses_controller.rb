class Api::V1::ResponsesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @responses = @user.responses
    render json: @responses.map { |response| response_json(response) }
  end

  private

  def response_json(response)
    {
      id: response.id,
      user_id: response.user_id,
      content: response.content,
      bot_response: response.bot_response
    }
  end
end