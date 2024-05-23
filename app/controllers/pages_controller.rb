class PagesController < ApplicationController
  include PagesHelper

  def intro
    @user = User.new
  end

  def create_user
    @user = User.new(user_params)
    if @user.save
      redirect_to chatbot_path(user_id: @user.id), notice: 'User was successfully created.'
    else
      render :intro
    end
  end

  def chatbot
    @user = User.find(params[:user_id])
    @response = @user.responses.build
    puts @user.name

    # Provide an initial question if there are no responses yet
    if @user.responses.empty?
      initial_question = generate_initial_response
      @user.responses.create(content: nil, bot_response: initial_question)
    end

    @responses = @user.responses.order(:created_at)
  end

  def create_response
    @user = User.find(params[:user_id])
    @response = @user.responses.build(response_params)

    if @response.save
      # Prepare conversation history
      conversation_history = build_conversation_history(@user.responses)

      # Generate bot response and save it
      bot_response_content = generate_response(@response.content, conversation_history)
      @response.update(bot_response: bot_response_content)

      redirect_to chatbot_path(user_id: @user.id), notice: 'Response saved successfully.'
    else
      @responses = @user.responses.order(:created_at)
      render :chatbot
    end
  end

  private

  def build_conversation_history(responses)
    responses.order(:created_at).flat_map do |response|
      [
        { role: "user", content: response.content.presence || "" },
        { role: "assistant", content: response.bot_response.presence || "" }
      ]
    end
  end

  def generate_initial_response
    "Hi there! Thank you for taking part in our survey. We value your time and feedback. To begin, we'd like to learn a little about your child's participation in sports. How old is your child?"
  end

  def user_params
    params.require(:user).permit(:name)
  end

  def response_params
    params.require(:response).permit(:content)
  end
end