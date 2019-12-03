require 'rails_helper'
require 'faker'

RSpec.describe Api::V1::Auth::UsersController, type: :controller do
  let!(:user) { create :user, id_number: "1111111111", password: "1234567890" }
  let(:params) do
    {
      name:       Faker::Name.first_name,
      last_name:  Faker::Name.last_name,
      id_number:  "1111111111",
      password:   "1234567890",
      department: "Tech",
      position:   "Software Engineer"
    }
  end

  before { allow_any_instance_of(described_class).to receive(:auth_params).and_return(params) }

  describe "#signup" do
    let!(:response) { {object: object, status: :created} }
    let!(:object)   do
      {
        exp:       "12-04-2019 12:04",
        id_number: 1111111111,
        token:     "eyJhbGc"
      }
    end

    subject { post :signup, params: params }

    before do
      allow(JwtService).to receive(:encode).and_return("eyJhbGc")
      allow_any_instance_of(described_class).to receive(:build_response).and_return(object)
    end

    context "when is a valid request" do
      it "calls Json web token service" do
        expect(JwtService).to receive(:encode)
        subject
      end

      it "create a new user" do
        expect {
          subject
        }.to change(User.all, :count).by(1)
      end

      it "returns the new token created" do
        expect_any_instance_of(described_class).to receive(:json_response).with(response)
        subject
      end
    end

    context "when is not a valid request" do
      let(:params)    { {name: "Carlos"} }
      let!(:response) { {object: object, status: :unprocessable_entity} }
      let!(:object) do
        {
          message: "Validation failed: Last name can't be blank, Id number can't be blank, Department can't be blank, Position can't be blank, Password can't be blank"
        }
      end

      it "returns 422 status" do
        expect_any_instance_of(described_class).to receive(:json_response).with(response)
        subject
      end
    end
  end

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
      let!(:response) { {object: object, status: :unauthorized} }
      let!(:object)   do
        {
          message: "invalid_credentials"
        }
      end
      
      context "if user does not exist" do
        let(:params) {{id_number: "00000"} }

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end

      context "if password is incorrect" do
        let(:params) { {password: "hello_world"} }

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end
  end
end
