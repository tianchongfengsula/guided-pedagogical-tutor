# app/jobs/ollama_stream_job.rb
class OllamaStreamJob < ApplicationJob
  queue_as :default

  def perform(ai_message_id, model_name, messages)
    ai_message = Message.find(ai_message_id)
    client = OllamaClient.new
    full_response = ""

    client.chat(model: model_name, messages: messages) do |token|
      full_response += token
      ai_message.update(content: full_response)
    end
  end
end
