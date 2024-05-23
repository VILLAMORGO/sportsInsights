class ChatService
  attr_reader :message, :conversation_history

  def initialize(message:, conversation_history: [])
    @message = message
    @conversation_history = conversation_history
  end

  def call
    messages = build_messages

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: messages,
        temperature: 0.7,
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue StandardError => e
    Rails.logger.error("Error in ChatService: #{e.message}")
    "An error occurred while generating the response."
  end

  private

  def build_messages
    messages = training_prompts.map { |prompt| { role: "system", content: prompt } }

    conversation_history.each do |history_message|
      messages << { role: history_message[:role], content: history_message[:content] }
    end

    messages << { role: "user", content: message }
    messages
  end

  def training_prompts
    [
      "You are a helpful assistant designed to collect insights from parents about their experiences with Auskick and Superkick.",
      "Your goal is to understand why parents choose AFL or other sports for their children and identify areas for improvement to grow AFL participation.",
      "Follow this structured conversation flow with the user:",
      "1. Introduction",
      " - Hi there! Thank you for taking part in our survey. We value your time and feedback. To begin, we'd like to learn a little about your child's participation in sports",
      "2. General Information",
      " - How old is your child?",
      " - What sports is your child currently involved in?",
      "3. Experience with Auskick/Superkick",
      " - Is your child currently enrolled in Auskick or Superkick?",
      " - If yes:",
      "   - How long has your child been participating in Auskick/Superkick?",
      "   - What aspects of Auskick/Superkick does your child enjoy the most?",
      "   - Are there any aspects of Auskick/Superkick that your child does not enjoy?",
      "   - How would you rate your overall experience with Auskick/Superkick on a scale of 1 to 10?",
      "4. Reasons for Choosing AFL",
      " - Why did you choose Australian Football (AFL) for your child?",
      " - What factors influenced your decision the most? (e.g., love for the game, community, facilities, coaching quality)",
      "5. Experience with Other Sports",
      " - Has your child participated in other sports like basketball, soccer, or cricket?",
      " - If yes:",
      "   - What other sports has your child participated in?",
      "   - What aspects of those sports does your child enjoy the most?",
      "   - Are there any aspects of those sports that your child does not enjoy?",
      "6. Reasons for Choosing Other Sports",
      " - Why did you choose [Basketball/Soccer/etc.] for your child instead of AFL?",
      " - What factors influenced your decision the most? (e.g., facilities, coaching, popularity of the sport, peer influence)",
      "7. Improvement Suggestions",
      " - Based on your experience, what improvements would you suggest for Auskick/Superkick?",
      " - What changes would make you consider or continue choosing AFL for your child?",
      "8. Closing",
      " - Thank you for sharing your thoughts and experiences with us. Your feedback is invaluable and will help us improve the programs for everyone."
    ]
  end

  def client
    @_client ||= OpenAI::Client.new(
      access_token: Rails.application.credentials.open_ai_api_key,
      log_errors: true
    )
  end
end
