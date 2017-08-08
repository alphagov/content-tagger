require 'rails_helper'

RSpec.describe NewProjectForm do
  include RemoteCsvHelper
  before :each do
    stub_remote_csv
  end
  describe '#create' do
    context 'valid form' do
      before :each do
        @valid_form = NewProjectForm.new(name: 'my_name', remote_url: RemoteCsvHelper::CSV_URL)
      end
      it 'is valid' do
        expect(@valid_form.create).to be_truthy
      end
      it 'creates a new Project' do
        expect { @valid_form.create }.to change { Project.count }.by(1)
      end
    end
    context 'invalid form' do
      it 'is invalid' do
        stub_request(:get, 'http://invalid_url').to_raise(SocketError)
        invalid_form = NewProjectForm.new(name: 'my_name', remote_url: 'http://invalid_url')
        expect(invalid_form.create).to be_falsey
      end
    end
  end
end
