require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe "#authorize_request" do
    let!(:payload) { {user_id: 1} }
    let!(:secret)  { Rails.application.secrets.secret_key_base}
    let!(:token)   { JWT.encode(payload, secret) }

    subject { described_class.new.authorize_request }

    #before { request.headers["Authorization"] = "1234" }

    context "when request is authorized" do
      context "when header request contains valid authorization token" do
        xit "calls Jwt service" do
          expect(JwtService).to receive(:decode)
          subject
        end

        xit "returns a valid user" do

        end
      end
    end

    context "when request can not be authorized" do
      context "when header request does not contains authorization token" do
        xit "do not call Jwt service" do
          expect(JwtService).not_to receive(:decode)
          subject
        end

        it "raise error" do
          expect { subject  }.to raise_error ExceptionHandler::MissingToken
        end
      end

      context "when header request contains an invalid authorization token" do
        xit "calls Jwt service" do

        end

        xit "raise error" do
          expect { subject }.to raise_error ExceptionHandler::InvalidToken
        end
      end
    end
  end
end
