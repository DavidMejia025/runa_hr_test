require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let!(:user)            { create :user, id_number: 123456, role: :admin,    password: "12345678" }
  let!(:not_admin_user)  { create :user, id_number: 100002, role: :employee, password: "12345678" }
  let(:params) do
    {
      user: {
        name:       user.name,
        last_name:  user.last_name,
        id_number:  100001,
        password:   user.password,
        role:       :admin,
        department: "Tech",
        position:   "Software Engineer"
      }
    }
  end

  before do
    controller.instance_variable_set(:@current_user, user)
    allow_any_instance_of(described_class).to receive(:authorize_request).and_return(user)
  end

  describe "#index" do
    let!(:user_2)         { create :user, id: 2, id_number: 123457 }
    let!(:user_3)         { create :user, id: 3, id_number: 123458 }
    let!(:users_response) { {object: object} }
    let!(:object) do
      [
        {
          department:  0,
          id_number:  user.id_number,
          last_name:  user.last_name,
          name:       user.name,
          position:  "Software Engineer"
        },
        {
          department:  0,
          id_number:  user_2.id_number,
          last_name:  user_2.last_name,
          name:       user_2.name,
          position:  "Software Engineer"
        },
        {
          department:  0,
          id_number:  user_3.id_number,
          last_name:  user_3.last_name,
          name:       user_3.name,
          position:  "Software Engineer"
        }
      ]
    end

    subject { get :index }

    before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

    context "fetch Users data" do
      it "returns user in json response" do
        expect_any_instance_of(described_class).to receive(:json_response).and_call_original
        subject
      end

      it "returns user in json response" do
        expect(subject.body).to match(object.to_json)
      end

      it "returns status 200" do
        expect(subject.status).to eq(200)
      end
    end
  end

  describe "#destroy" do
    let(:params) { {id_number: 123456} }

    subject { delete :destroy, params: params }

    context "when curren_user is admin user" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when User exist" do
        it "deletes the user" do
          expect {
            subject
          }.to change(User.all, :count).by(-1)
        end

        it "returs status ok" do
          expect(response.status).to eq(200)
          subject
        end
      end

      context "when user does not exist" do
        let(:params)    { {id_number: 10} }
        let!(:response) { {object: object, status: :not_found} }
        let!(:object)   do
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

    context "when current_user is not an admin_user" do
      let(:params)    { {id_number: 100002} }
      let!(:response) { {object: object, status: :unauthorized} }
      let!(:object)   do
        {
          message: "User is not admin"
        }
      end

      before { controller.instance_variable_set(:@current_user, not_admin_user) }

      it "returns unauthorized response" do
        expect_any_instance_of(described_class).to receive(:json_response)
          subject
      end
    end
  end

  describe "#create" do
    subject { get :create, params: params }

    before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

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
      let(:params)    { {user: {name: "David"}} }
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

  describe "#show" do
    subject { get :show, params: params }

    context "when user can be fetched" do
      let(:params)         { {id_number: 123456} }
      let!(:user_response) { {object: object} }
      let!(:object)   do
        {
          name:       user.name,
          last_name:  user.last_name,
          id_number:  user.id_number,
          department: user.department,
          position:   user.position,
          role:       user.role
        }
      end

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

    context "when user can not be fetch" do
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

  describe "#update" do
    let(:id_number) { {id_number: 123456} }
    let(:params) do
      {
        user: {
          name:       "Andres",
          last_name:  "Bonilla",
          id_number:  99999,
          department: :Product,
          position:   "Product designer"
        }
      }
    end

    subject { put :update, params: params.merge(id_number: id_number) }

    context "when user is admin" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when user can be updated" do
        let(:id_number) { user.id_number }

        it "name change" do
          expect {
            subject
          }.to change {
            user.reload.name
          }.to("Andres")
        end

        it "last_name change" do
          expect {
            subject
          }.to change {
            user.reload.last_name
          }.to("Bonilla")
        end

        it "id_number change" do
          expect {
            subject
          }.to change {
            user.reload.id_number
          }.to(99999)
        end

        it "department change" do
          expect {
            subject
          }.to change {
            user.reload.department
          }.to("Product")
        end

        it "postition change" do
          expect {
            subject
          }.to change {
            user.reload.position
          }.to("Product designer")
        end

        it "returs status ok" do
          expect(response.status).to eq(200)
          subject
        end
      end

      context "when user cannot be updated" do
        let!(:id_number) { 2 }
        let!(:response)  { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "Couldn't find User with id_number=2"
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
