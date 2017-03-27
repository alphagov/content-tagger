require 'rails_helper'

RSpec.describe Taxonomy::EmailSignupPage do
  describe '#payload' do
    it 'conforms to the email_alert_signup schema' do
      expect(Taxonomy::EmailSignupPage.new.payload)
        .to be_valid_against_schema('email_alert_signup')
    end
  end
end
