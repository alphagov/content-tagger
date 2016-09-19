require 'rails_helper'

RSpec.describe TagMapping do
  context '#messages' do
    it 'serializes the messages as an array' do
      expect { subject.messages = ['a message'] }.to_not raise_error
    end

    it "doesn't allow other types in the messages field" do
      expect { subject.messages = 'a message' }.to raise_error(
        ActiveRecord::SerializationTypeMismatch
      )
    end
  end
end
