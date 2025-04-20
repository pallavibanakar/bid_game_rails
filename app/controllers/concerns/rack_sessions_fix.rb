module RackSessionsFix
  extend ActiveSupport::Concern

  included do
    before_action :set_fake_session
    private
    def set_fake_session
      request.env["rack.session"] ||= FakeRackSession.new
    end
  end

  class FakeRackSession < Hash
    def enabled?
      false
    end
    def destroy; end
  end
end
