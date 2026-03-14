class AsyncLogJob < ApplicationJob
  queue_as :async_log

  retry_on StandardError, wait: 3.seconds, attempts: 3
  retry_on ArgumentError, wait: 3.seconds, attempts: 3

  def perform(message: "hello")
    AsyncLog.create!(message: message)
  end
end