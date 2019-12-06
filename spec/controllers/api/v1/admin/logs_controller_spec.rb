require 'rails_helper'
require 'faker'

RSpec.describe Api::V1::Admin::LogsController, type: :controller do
  let!(:user)        { create :user, id_number: 1, role: :admin, password: "12345678" }
  let!(:log)         { create :log, user_id: user.id }
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
    let(:params) { {id: log.id} }

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

  describe "#report" do
    let(:employee)       { create :user, id: 3,  role: :employee }
    let!(:log_1)         { create :log,  :complete, id: 3, user_id: employee.id }
    let!(:log_2)         { create :log,  :complete, id: 4, user_id: employee.id }
    let!(:log_3)         { create :log,  :complete, id: 5, user_id: employee.id }
    let(:params) do
      {
        id_number: employee_id,
        start_day: start_day,
        end_day:   end_day
      }
    end

    subject { get :report, params: params }

    context "when user is an admin" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when employee exist" do
        let(:employee_id)  { employee.id_number }

        context "when there are records inside start_day and end_day range" do
          let!(:start_day)   { "20190101T083748-0500" }
          let!(:end_day)     { "20200101T083748-0500" }
          let(:report) do
            {
              employee_id: employee_id,
              total_logs: 3,
              logs: [
                  {
                    check_in:  log_1.check_in,
                    check_out: log_1.check_out
                  },
                  {
                    check_in:  log_2.check_in,
                    check_out: log_2.check_out
                  },
                  {
                    check_in:  log_3.check_in,
                    check_out: log_3.check_out
                  }
              ]
            }.to_json
          end

          it "gets the report containing 3 log records" do
            expect(subject.body).to eq(report)
          end
        end

        context "when there are not records inside start_day and end_day range" do
          let!(:start_day)   { "20190101T083748-0500" }
          let!(:end_day)     { "20190201T083748-0500" }
          let(:report) do
            {
                employee_id: employee_id,
                total_logs:  0,
                logs:        []
            }.to_json
          end

          it "gets the report containing 0 log records" do
            expect(subject.body).to eq(report)
          end
        end
      end

      context "when employee does not exist" do
        let(:employee_id)  { 100 }
        let!(:start_day)   { "20190101T083748-0500" }
        let!(:end_day)     { "20190201T083748-0500" }
        let!(:response)     { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "Couldn't find User with 'id_number'=100"
          }
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response)
          subject
        end

        it "returs body with error message" do
          expect(subject.body).to eq(object.to_json)
          subject
        end

        it "returs status :not_found" do
          expect(subject.status).to eq(404)
          subject
        end
      end
    end

    context "when current_user is not an admin_user" do
      let(:employee_id)   { employee.id_number }
      let!(:start_day)   { "20190101T083748-0500" }
      let!(:end_day)     { "20190201T083748-0500" }
      let!(:current_user) { create :user, id: 4, id_number: 012345, role: :employee }
      let!(:response)     { {object: object, status: :unauthorized} }
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

  describe "#update" do
    let(:id) { log.id }
    let(:params) do
      {
        id_number: user.id_number,
        check_in:  Faker::Time.backward(days: 5, period: :morning),
        check_out: Faker::Time.backward(days: 5, period: :evening)
      }
    end

    subject { put :update, params: params.merge({id: id}) }

    context "when user is admin" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when log can be updated" do
        let(:id_number) { user.id_number }

        it "the check_in field change" do
          expect {
            subject
          }.to change {
            log.reload.check_in
          }.to(params[:check_in])
        end

        it "last_name change" do
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

      context "when log cannot be updated" do
        let!(:id) { 10 }
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
end
