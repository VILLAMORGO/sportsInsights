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
    puts @user.responses.all.inspect

    if @user.responses.all.empty?
      initial_question = generate_initial_response
      @initial_response = @user.responses.create(content: nil, bot_response: initial_question)
      if @initial_response.persisted?
        puts "Initial question: #{initial_question}" 
      else
        puts "Failed to save initial question"
      end
    end

    @responses = @user.responses.order(:created_at)
    puts @responses.inspect  
  end

  def create_response
    @user = User.find(params[:user_id])
    @response = @user.responses.build(response_params)
  
    if @response.save
      conversation_history = build_conversation_history(@user.responses)
      bot_response_content = generate_response(@response.content, conversation_history)
      @response.update(bot_response: bot_response_content)
  
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { user_message: @response.content, bot_response: bot_response_content } }
      end
    else
      @responses = @user.responses.order(:created_at)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("messages", partial: "pages/messages", locals: { responses: @responses, user: @user }) }
        format.json { render json: { error: 'Error saving response' }, status: :unprocessable_entity }
      end
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
    conversation_history = [] 
    chat_service = ChatService.new(message: "Generate introduction with initial question", conversation_history: conversation_history)
    chat_service.call
  end

  def user_params
    params.require(:user).permit(:name)
  end

  def response_params
    params.require(:response).permit(:content)
  end
end