class Message < ApplicationRecord
  after_create_commit -> { broadcast_append_to "messages" }
  after_update_commit -> { broadcast_replace_to "messages" }

  # NOTE: Stop button's clean up -> connected to the chats#stop
  after_destroy_commit -> { broadcast_remove_to "messages" }
end
