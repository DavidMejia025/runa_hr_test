require 'rails_helper'

RSpec.describe JwtService, type: :service do
  describe "#encode" do
    subject { described_class.encode(payload: payload) }

    it "calls JWT encode method" do

    end

    it "returns a valid token" do
      
    end
  end

  describe "#dencue" do
    subject { described_class.decode(token: token) }

    it "calls JWT decode method" do

    end

    context "when token exists" do
      it "retunrs valid user id" do

      end
    end

    context "when token does not exist" do
      it "rise invalid token error" do

      end
    end
  end
end
