require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let!(:user)        { create :user, id: 1, id_number: 123456, role: :admin, password: "12345678" }
  let(:current_user) { user }
  let(:params) do
    {
      name:       user.name,
      last_name:  user.last_name,
      id_number:  123456,
      password:   user.password,
      role:       :admin,
      department: "Tech",
      position:   "Software Engineer"
    }
  end

  before do
    allow_any_instance_of(described_class).to receive(:authorize_request).and_return(user)
  end

  describe "#show" do
    subject { get :show, params: params }

    context "when user can be fetched user information" do
      let(:params)         { {id_number: 123456} }
      let!(:user_response) { {object: object} }
      let!(:object)   do
        {
          user: {
            name:       user.name,
            last_name:  user.last_name,
            id_number:  user.id_number,
            department: user.department,
            position:   user.position,
            role:       user.role
          }
        }
      end

      #before { described_class.instance_variable_set(:@current_user, user) }
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      it "returns user in json response" do
       expect_any_instance_of(described_class).to receive(:json_response).with(user_response).and_call_original
       subject
      end

      it "returns user in json response" do
        expect(subject.body).to eq(object.to_json)
      end

      it "returns status 200" do
        expect(subject.status).to eq(200)
      end
    end

    context "when user can not be fetch user information" do
      context "when current user request user information from another user" do
        let!(:user)          { create :user, id: 2, id_number: 000000}
        let(:params)        { {id_number: 000000} }
        let!(:current_user) { create :user, id: 4, id_number: 012345, role: :employee }
        let!(:response)     { {object: object, status: :unprocessable_entity} }
        let!(:object)   do
          {
            message: "token does not corresponds to the user requested information"
          }
        end

        before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(false) }

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end

      context "when user does not exist" do
        let(:params)    { {id_number: 10} }
        let!(:response) { {object: object, status: :not_found} }
        let!(:object) do
          {
            message: "Couldn't find User with id_number=10"
          }
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end
  end

  describe "#update_password" do
    let(:params) do
      {
        password:                  password,
        new_password:              "new_pasword123",
        new_password_confirmation: "new_pasword123",
        id_number:                 user.id_number
      }
    end

    subject { put :update_password, params: params }

    before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

    context "when user can update password" do
      context "if user password is valid and new_password is eq to new_password_confirmation" do
        let(:password) { user.password }

        it "uodate password" do
          expect {
            subject
          }.to change {
            user.reload.password
          }.to("new_pasword123")
        end
      end
    end

    context "when user cannot update password" do
      context "if user password is invalid" do
        let(:password) { "wrong_password" }
        let!(:response) { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "invalid_credentials"
          }
        end

        it "returns user in json response" do
          expect(subject.body).to match(object.to_json)
        end

        it "returns status 401" do
          expect(subject.status).to eq(401)
        end
      end

      context "if user new_password doesnt match" do
        let(:params) do
          {
            password:                  user.password,
            new_password:              "new_pasword123",
            new_password_confirmation: "new",
          }
        end
        let!(:response) { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "invalid_credentials"
          }
        end

        it "returns user in json response" do
          expect(subject.body).to match(object.to_json)
        end

        it "returns status 401" do
          expect(subject.status).to eq(401)
        end
      end

      context "when current user request user information from another user" do
        let!(:user)         { create :user, id: 2, id_number: 000000}
        let(:params)        { {id_number: 000000} }
        let!(:current_user) { create :user, id: 4, id_number: 012345, role: :employee }
        let!(:response)     { {object: object, status: :unprocessable_entity} }
        let!(:object)   do
          {
            message: "token does not corresponds to the user requested information"
          }
        end

        before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(false) }

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
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

    context "when user is current user" do
      context "when employee exist" do
        let(:employee_id)  { employee.id_number }

        context "when there are records inside start_day and end_day range" do
          let!(:start_day)   { "20190101T083748-0500" }
          let!(:end_day)     { "20200101T083748-0500" }
          let(:report) do
            {
              employee_id: 3,
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
                employee_id: 3,
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
            message: "User with id_number=100 does not exist"
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

    context "when current user request user information from another user" do
      let!(:user)          { create :user, id: 2, id_number: 000000}
      let(:params)        { {id_number: 000000} }
      let!(:current_user) { create :user, id: 4, id_number: 012345, role: :employee }
      let!(:response)     { {object: object, status: :unprocessable_entity} }
      let!(:object)   do
        {
          message: "token does not corresponds to the user requested information"
        }
      end

      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(false) }

      it "returns unauthorized response" do
        expect_any_instance_of(described_class).to receive(:json_response).with(response)
        subject
      end
    end
  end
end
