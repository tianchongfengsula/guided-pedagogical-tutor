class OllamaClient
  require "net/http"
  require "json"

  OLLAMA_URL = "http://localhost:11434"

  def chat(model:, messages:)
    uri = URI("#{OLLAMA_URL}/api/chat")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      request.body = { model: model, messages: messages, stream: true }.to_json

      http.request(request) do |response|
        response.read_body do |chunk|
          # Ollama sends multiple JSON objects. We yield the content piece by piece.
          json = JSON.parse(chunk)
          content = json.dig("message", "content")
          yield content if block_given? && content
        end
      end
    end
  rescue => e
    yield "Error: #{e.message}" if block_given?
  end
end
