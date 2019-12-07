require 'rails_helper'

RSpec.describe JwtService, type: :service do
  let!(:secret)  { "CAB577FAF0FEC295C212B4F93C823129F5A6CCA774B4182BD34A4C9FB71789C3" }
  let!(:payload) { {user_id: 1} }

  describe "#encode" do
    subject { described_class.encode(payload: payload) }

    it "calls JWT encode method" do
      expect(JWT).to receive(:encode)
      subject
    end
  end

  describe "#decode" do
    let!(:token) { JWT.encode(payload, secret) }

    subject { described_class.decode(token: token) }

    it "calls JWT decode method" do
      expect(JWT).to receive(:decode)
      subject
    end

    context "when token exists" do
      it "retunrs valid user id" do
        expect(subject).to eq({"user_id" => 1})
      end
    end

    context "when token is invalid" do
      let(:token) { "1234567890" }

      it "rise invalid token error" do
        expect { subject }.to raise_error ExceptionHandler::InvalidToken
      end
    end
  end
end
