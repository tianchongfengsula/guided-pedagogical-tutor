class ChatsController < ApplicationController
  before_action :set_display_model_name, only: %i[index create]

  def index
    @messages = Message.all
  end

=begin
WARNING: To self, DO not remove
def create
  Message.create!(role: 'user', content: params[:message])
  ai_message = Message.create!(role: 'assistant', content: "")
  OllamaStreamJob.perform_later(ai_message.id, @model_name, build_messages_with_db)
  head :ok  # returns immediately, job streams in background
end
=end

def create
  Message.create!(role: "user", content: params[:message])
  ai_message = Message.create!(role: "assistant", content: "")
  messages = build_messages_with_db
  model = @model_name

  thread = Thread.new do
    ActiveRecord::Base.connection_pool.with_connection do
      client = OllamaClient.new
      full_response = ""
      client.chat(model: model, messages: messages) do |token|
        full_response += token
        ai_message.update(content: full_response)
      end
      # ← Signal JS that streaming is truly done
      Turbo::StreamsChannel.broadcast_action_to "messages", action: "streamingDone", target: "messages"
    end
  end

  session[:streaming_thread_id] = thread.object_id
  $streaming_threads ||= {}
  $streaming_threads[thread.object_id] = thread

  head :ok
end

def stop
  thread_id = session[:streaming_thread_id]
  if thread_id && $streaming_threads&.[](thread_id)
    $streaming_threads[thread_id].kill
    $streaming_threads.delete(thread_id)
  end

  # NOTE: Find the message.rb's after_destroy_commit are connected
  # Clean up any empty assistant messages left behind
  Message.where(role: "assistant", content: [ nil, "" ]).destroy_all

  head :ok
end

  def clear
    Message.destroy_all
    redirect_to root_path
  end

  private

  def build_messages_with_db
    example_prompt = <<~EXAMPLES
      Q: Who is the head of the IT department?
      A: What role does the person you’re thinking of play in the department’s daily operations?
      Q: I can’t remember the email address for Ms. Santos.
      A: Think about the pattern of the email usernames we’ve seen for other staff members. Does that help you reconstruct it?
    EXAMPLES
    people_data = <<~PROMPT
    Mr. Angelo Padrid: Student of Letran Manaoag, Letran GPT's Capstone Leader
    Rev. Fr. Jessie R. Yap, OP, EHL: Rector and President
    Rev. Fr. Felix Legaspi III, OP, MA: Vice President for Finance
    Rev. Fr. Samuel Sonny Gunawan, OP, MA: Vice President for Religious Affairs
    Ms. Nadine T. Tersol, LPT, MEd: Vice President for Academics & Research
    Ms. Lenigrace Mecias, DIT: Assitant to the President for Scholarship & Grants
    Ms. Nadine T. Tersol, LPT, MEd: VP for Academics
    Mr. John  Ivan S. Cleofe, LPT,  MST, PhD: Dean, Higher Education Department
    Dr. Kathryn P. Acosta, DIT: Vice-Dean, Higher Education Department and Also 3rd year's Capstone Adviser
    Mr. Raymond Allan J. Tiquia, MIT: Information Technology Program Head & ITM Officer
    Mr. Eugene A. Estacio: Technical Education Officer
    PROMPT
    socratic_prompt = <<~FULL_PROMPT
      #{example_prompt}

      You are LetranGPT, an expert tutor for Letran Manaoag staff data.
      Respond to every question using the Socratic method:
        • Start with a clarifying or probing question.
        • Offer only one small hint if the learner is stuck.
        • Never give the full answer directly.
      Staff data you may reference: #{people_data}
      If something is unknown, say so.
    FULL_PROMPT
    system_prompt = { "role" => "system", "content" => "#{socratic_prompt}" }

    # Convert DB records to the format Ollama expects
    history = Message.all.map { |m| { "role" => m.role, "content" => m.content } }
    [ system_prompt ] + history
  end

  def set_display_model_name
    @model_name = "lfm2.5-thinking"
    # @model_name = 'llama3'
    # @model_name = 'llama3.2:3b'
  end
end
