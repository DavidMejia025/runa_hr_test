require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe "#authorize_request" do
    subject { pdescribe_class.authorize_request }

    context "when request is authorized" do
      context "when header request contains valid authorization token" do
        it "calls Jwt service" do

        end

        it "returns a valid user" do

        end
      end
    end

    context "when request can not be authorized" do
      context "when header request does not contains authorization token" do
        it "do not call Jwt service" do

        end

        it "raise error" do

        end
      end

      context "when header request contains an invalid authorization token" do
        it "calls Jwt service" do

        end

        it "raise error" do

        end
      end
    end
end
