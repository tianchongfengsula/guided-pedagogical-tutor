require "test_helper"

class PingOllamaApiTest < ActiveSupport::TestCase
  test "ollama is running and responds at root" do
    response = Net::HTTP.get_response(URI("http://localhost:11434/"))
    
    puts "\n[/] Ollama status: #{response.code} — #{response.body}"

    assert_equal "200", response.code,
      "Expected 200 but got #{response.code}. Is Ollama running?"
    assert_match(/Ollama is running/, response.body,
      "Response did not confirm Ollama is running. Body: #{response.body}")
  end
end
