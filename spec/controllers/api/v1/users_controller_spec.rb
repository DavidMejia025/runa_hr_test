require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe "#index" do
    subject { get :index, params: {search_input: search_input} }

    context "fetch Users data" do
      it "returns users" do
      end

      it "returns status ok" do

      end
    end
  end

  describe "#destroy" do
    subject { delete :destroy, params: param }

    context "when User exist" do
      it "deletes the user" do
        expect {
          subject
        }.to change(Task.all, :count).by(-1)
      end
    end

    context "when user does not exist" do
      it "returns no record found message" do

      end
    end
  end

  describe "#create" do
    subject { get :create, params: param }

    context "when user can be created" do
      it "users counter increased by one" do
      end
    end

    context "when task can not be created" do
      it "number of users does not change" do
      end
    end
  end

  describe "#show" do
    subject { get :show, params: param }

    context "when user can be fetched" do
    end

    context "when user can not be fetch" do
      context "when user does not exist" do
      end
    end
  end

  describe "#update" do
    subject { get :update, params: param }

    context "when task can be updated" do
      context "when update all records" do
      end
    end

    context "when task can not be updated" do
      context "when there are some fields missing" do
      end

      context "when task does not exist" do
      end
    end
  end
end
