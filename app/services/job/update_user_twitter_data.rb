module Job
  class UpdateUserTwitterData
    include TwitterAPIClient
    attr_reader :notify_logs

    def initialize(users = User.not_deleted)
      @users = users
      @notify_logs = []
    end

    def call
      @users.each do |user|
        fetch(user)
      end
    end

    private

    def fetch(user)
      TwitterAPI::User.new(user).call
    rescue StandardError => e
      message = "@#{user.screen_name}: #{e}"
      notify_logs << message && Rails.logger.error(message)
    end
  end
end
