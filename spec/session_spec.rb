require 'spec_helper'

describe FreebaseAPI::Session do

  let(:session) { FreebaseAPI::Session.new }
  let(:dummy_session) { FreebaseAPI::Session.new(:key => "GOOGLE_API_KEY", :env => :sandbox, :query_options => { :lang => :fr, :limit => 1 }) }

  it "should include HTTParty" do
    FreebaseAPI::Session.should include(HTTParty)
  end

  describe "#key" do
    it "should return the API key" do
      dummy_session.key.should == 'GOOGLE_API_KEY'
    end
  end

  describe "#env" do
    it "should return the environnment" do
      dummy_session.env.should == :sandbox
    end
  end

  describe "#query_options" do
    it "should return the environnment" do
      dummy_session.query_options.should == { :lang => :fr, :limit => 1 }
    end
  end

  describe "#surl" do
    context "in a sandbox environnment" do
      it "should return the sandbox service URL" do
        dummy_session.send(:surl, 'service').should == 'https://www.googleapis.com/freebase/v1sandbox/service'
      end
    end

    context "in a stable environnment" do
      it "should return the sandbox service URL" do
        session.send(:surl, 'service').should == 'https://www.googleapis.com/freebase/v1/service'
      end
    end
  end

  describe "#mqlread" do
    let(:query) {
      {
        :type => '/internet/website',
        :id => '/en/github',
        :'/common/topic/official_website' => nil
      }
    }

    let(:request) {
      session.mqlread(query)
    }

    context "when the query is successful" do
      it "should run a MQL query and return the result" do
        request.should == {
          "/common/topic/official_website" => "http://github.com/",
          "id" => "/en/github",
          "type" => "/internet/website"
        }
      end
    end

    context "when the query has failed" do
      let(:session) { FreebaseAPI::Session.new :key => 'nil' }

      it "should raise en error" do
        expect {
          request
        }.to raise_error(FreebaseAPI::Error)
      end
    end
  end

  describe "#topic" do
    let(:request) {
      session.topic('/en/github', :filter => '/common/topic/official_website')
    }

    context "when the query is successful" do
      it "should run a topic query and return the result" do
        request['property'].should have(1).elements
      end
    end

    context "when the query has failed" do
      let(:session) { FreebaseAPI::Session.new :key => 'nil' }

      it "should raise en error" do
        expect {
          request
        }.to raise_error(FreebaseAPI::Error)
      end
    end
  end
end