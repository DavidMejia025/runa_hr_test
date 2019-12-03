require 'rails_helper'

RSpec.describe Api::V1::Auth::UsersController, type: :controller do
  describe "#signup" do
    subject { post :signup, params: params }

    context "when is a valid request" do
\     it "calls Json web token service" do

      end

      it "create a new user" do

      end

      it "returns the new token created" do

      end

      it "returns 200 status" do

      end
    end

    context "when is not a valid request" do
      it "return 422 status" do

      end
    end
  end

  describe "login" do

    subject { post :login, params: params }

    context "when is a valid request" do
      context "when all require params are present" do
        it "calls Json web token service" do

        end

        it "returns the new token created" do

        end

        it "returns 200 status" do

        end
      end
    end

    context "when is not a valid request" do
      it "returns 422 status" do
      end
    end
  end
end
