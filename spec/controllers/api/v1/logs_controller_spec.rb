require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let!(:user)        { create :user, id: 1, role: :admin, password: "12345678" }
  let(:current_user) { user }
  let(:params) do
    {
      arrival_time:       user.name,
      last_name:  user.last_name,
      id_number:  user.id_number,
      password:   user.password,
      role:       :admin,
      department: "Tech",
      position:   "Software Engineer"
    }
  end

  before do
    allow_any_instance_of(described_class).to receive(:authorize_request).and_return(user)
    allow_any_instance_of(described_class).to receive(:admin_only).and_return(true)
  end

  describe "#create" do
    subject { get :create, params: params }

    before { allow_any_instance_of(described_class).to receive(:admin_only).and_return(true) }

    context "when user can be created" do
      it "users counter increased by one" do
        expect {
          subject
        }.to change(User.all, :count).by(1)
      end

      it "returs status ok" do
        expect(response.status).to eq(200)
        subject
      end
    end

    context "when user can not be created" do
      let(:params)    { {name: "David"} }
      let!(:response) { {object: object, status: :unprocessable_entity} }
      let!(:object)   do
        {
          message: "Validation failed: Last name can't be blank, Id number can't be blank, Department can't be blank, Position can't be blank, Password can't be blank"
        }
      end

      it "number of users does not change" do
        expect {
          subject
        }.to change(User.all, :count).by(0)
      end

      it "returns unauthorized response" do
        expect_any_instance_of(described_class).to receive(:json_response).with(response)
        subject
      end
    end
  end
end
