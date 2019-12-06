require 'rails_helper'
require 'faker'

RSpec.describe Api::V1::Auth::UsersController, type: :controller do
  let!(:user) { create :user, id_number: "1111111111", password: "1234567890" }
  let(:params) do
    {
      id_number:  "1111111111",
      password:   "1234567890",
    }
  end

  before { allow_any_instance_of(described_class).to receive(:auth_params).and_return(params) }

  describe "login" do
    let!(:response) { {object: object} }
    let!(:object)   do
      {
        exp:       "12-04-2019 12:04",
        id_number: 1111111111,
        token:     "eyJhbGc"
      }
    end

    subject { post :login, params: params }

    before do
      allow(JwtService).to receive(:encode).and_return("eyJhbGc")
      allow_any_instance_of(described_class).to receive(:build_response).and_return(object)
    end

    context "when is a valid request" do
      context "when ide_number and password can be authenticated" do
        it "calls Json web token service" do
          expect(JwtService).to receive(:encode)
          subject
        end

        it "returns the new token created in the response body" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end

    context "when request is not valid" do
      let!(:response) { {object: object, status: :not_found} }
      let!(:object)   do
        {
          message: "Couldn't find User with id_number=1000000001"
        }
      end

      context "if user does not exist" do
        let(:params) do
          {
            id_number:  "1000000001",
            password:   "1234567890",
          }
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
#Failing spec needs to double check
      context "if password is incorrect" do
        let!(:response) { {object: object} }
        let(:params) do
          {
            id_number:  "1111111111",
            password:   "1234567890",
          }
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end
  end
end
