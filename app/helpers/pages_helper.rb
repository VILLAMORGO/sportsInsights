module PagesHelper
  def generate_response(message, conversation_history = [])
    if message.blank?
      "Hi there! Thank you for taking part in our survey. We value your time and feedback. To begin, we'd like to learn a little about your child's participation in sports. How old is your child?"
    else
      ChatService.new(message: message, conversation_history: conversation_history).call || "Error generating response."
    end
  end
end