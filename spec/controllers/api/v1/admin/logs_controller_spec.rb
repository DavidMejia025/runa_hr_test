require 'rails_helper'
require 'faker'

RSpec.describe Api::V1::Admin::LogsController, type: :controller do
  let!(:user)        { create :user, id: 1, role: :admin, password: "12345678" }
  let!(:log)         { create :log,  id: 1, user_id: user.id }
  let(:current_user) { user }
  let(:params) do
    {
      id_number: user.id_number,
      check_in:  Faker::Time.backward(days: 7, period: :morning),
      check_out: Faker::Time.backward(days: 7, period: :evening)
    }
  end

  before do
    allow_any_instance_of(described_class).to receive(:authorize_request).and_return(user)
  end

  describe "#create" do
    subject { get :create, params: params }

    context "when user is an admin user" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when log can be created" do
        it "logs counter increased by one" do
          expect {
            subject
          }.to change(Log.all, :count).by(1)
        end

        it "returs status ok" do
          expect(response.status).to eq(200)
          subject
        end
      end

      context "when log can not be created" do
        let(:params) do
          {
            id_number: user.id_number,
            check_out: Time.parse("20191204T173748-0500")
          }
        end
        let!(:response) { {object: object, status: :unprocessable_entity} }
        let!(:object)   do
          {
            message: "Validation failed: Check in can't be blank"
          }
        end

        it "number of logs does not change" do
          expect {
            subject
          }.to change(Log.all, :count).by(0)
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end

    context "when current_user is not an admin_user" do
      let!(:current_user) { create :user, id:2, id_number: 012345, role: :employee }
      let!(:response)    { {object: object, status: :unauthorized} }
      let!(:object)   do
        {
          message: "User is not admin"
        }
      end

      it "returns unauthorized response" do
        expect_any_instance_of(described_class).to receive(:json_response).with(response)
        subject
      end
    end
  end

  describe "#destroy" do
    let(:params) { {id: 1} }

    subject { delete :destroy, params: params }

    context "when curren_user is admin user" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when Log exist" do
        it "deletes the user" do
          expect {
            subject
          }.to change(Log.all, :count).by(-1)
        end

        it "returs status ok" do
          expect(response.status).to eq(200)
          subject
        end
      end

      context "when user does not exist" do
        let(:params) { {id: 10} }
        let!(:response) { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "Couldn't find Log with 'id'=10"
          }
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end
  end

  describe "#check_in" do
    subject { get :create, params: params }

    context "when user is an admin user" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when log can be created" do
        it "logs counter increased by one" do
          expect {
            subject
          }.to change(Log.all, :count).by(1)
        end

        it "returs status ok" do
          expect(response.status).to eq(200)
          subject
        end
      end

      context "when log can not be created" do
        let(:params) do
          {
            id_number: user.id_number,
            check_out: Faker::Time.backward(days: 7, period: :evening)
          }
        end
        let!(:response) { {object: object, status: :unprocessable_entity} }
        let!(:object)   do
          {
            message: "Validation failed: Check in can't be blank"
          }
        end

        it "number of logs does not change" do
          expect {
            subject
          }.to change(Log.all, :count).by(0)
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end
  end

  describe "#check_out" do
    let(:id) { {id: 1} }
    let(:params) do
      {
        id_number: user.id_number,
        check_out: Faker::Time.backward(days: 5, period: :evening)
      }
    end

    subject { get :check_out, params: params }

    context "when user is admin" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when log can register check_out" do
        it "name change" do
          expect {
            subject
          }.to change {
            log.reload.check_out
          }.to(params[:check_out])
        end

        it "returs status ok" do
          expect(response.status).to eq(200)
          subject
        end
      end

      context "when log cannot be register check_out" do
        context "when log check_out has already been register" do
          let!(:log) do
            create :log,
            id: 2,
            user_id: user.id,
            check_in:  Faker::Time.backward(days: 5, period: :morning),
            check_out: Faker::Time.backward(days: 5, period: :evening)
          end
          let!(:response) { {object: object, status: :unprocessable_entity} }
          let!(:object)   do
            {
              message: "User #{user.id_number} already left the office please contact your manager to fix logs"
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
end
