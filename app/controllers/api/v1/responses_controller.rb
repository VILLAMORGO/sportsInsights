class Api::V1::ResponsesController < ApplicationController
  def index
    @users = User.includes(:responses).all
    render json: @users.map { |user| user_responses_json(user) }
  end

  private

  def user_responses_json(user)
    {
      user_id: user.id,
      responses: user.responses.map { |response| response_json(response) }
    }
  end

  def response_json(response)
    {
      id: response.id,
      user_id: response.user_id,
      content: response.content,
      bot_response: response.bot_response
    }
  end
end