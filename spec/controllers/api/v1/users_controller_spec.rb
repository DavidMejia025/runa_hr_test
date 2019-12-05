require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let!(:user)        { create :user, id: 1, role: :admin, password: "12345678" }
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

  describe "#index" do
    let!(:user_2)         { create :user, id: 2 }
    let!(:user_3)         { create :user, id: 3 }
    let!(:users_response) { {object: object} }
    let!(:object) do
      [
          {
            user: {
              department:  0,
              id_number:  user.id_number,
              last_name:  user.last_name,
              name:       user.name,
              position:  "Software Engineer"
            }
          },
          {
            user: {
              department:  0,
              id_number:  user_2.id_number,
              last_name:  user_2.last_name,
              name:       user_2.name,
              position:  "Software Engineer"
            }
          },
          {
            user: {
              department:  0,
              id_number:  user_3.id_number,
              last_name:  user_3.last_name,
              name:       user_3.name,
              position:  "Software Engineer"
            }
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
    let(:params) { {id: 1} }

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
        let(:params) { {id: 10} }
        let!(:response) { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "Couldn't find User with 'id'=10"
          }
        end

        it "returns unauthorized response" do
          expect_any_instance_of(described_class).to receive(:json_response).with(response)
          subject
        end
      end
    end

    context "when current_user is not an admin_user" do
      let!(:response) { {object: object, status: :unauthorized} }
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

  describe "#show" do
    subject { get :show, params: params }

    context "when user can be fetched" do
      let(:params) { {id: 1} }
      let!(:user_response) { {object: object} }
      let!(:object)   do
        {
          user: {
            name:       user.name,
            last_name:  user.last_name,
            id_number:  user.id_number,
            department: user.department,
            position:   user.position
          }
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
      let(:params)    { {id: 10} }
      let!(:response) { {object: object, status: :not_found} }
      let!(:object) do
        {
          message: "Couldn't find User with 'id'=10"
        }
      end

      it "returns unauthorized response" do
        expect_any_instance_of(described_class).to receive(:json_response).with(response)
        subject
      end
    end
  end

  describe "#update" do
    let(:id) { {id: 1} }
    let(:params) do
      {
        name:       "Andres",
        last_name:  "Bonilla",
        id_number:  99999,
        department: 1,
        position:   "Product designer"
      }
    end

    subject { put :update, params: params.merge(id) }

    context "when user is admin" do
      before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

      context "when user can be updated" do
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
          }.to(1)
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
        let(:id)        { {id: 2} }
        let!(:response) { {object: object, status: :not_found} }
        let!(:object)   do
          {
            message: "Couldn't find User with 'id'=2"
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

    subject { put :update_password, params: params.merge({user_id: 1}) }

    before { allow_any_instance_of(described_class).to receive(:admin_only?).and_return(true) }

    context "when user password is valid" do
      let(:password) { user.password }

      it "uodate password" do
        expect {
          subject
        }.to change {
          user.reload.password
        }.to("new_pasword123")
      end
    end

    context "when user passwor is invalid" do
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

    context "when user new_password doesnt match" do
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
  end
end
