require 'spec_helper'

describe FreebaseAPI::Session do

  let(:session) { FreebaseAPI::Session.new }
  let(:dummy_session) { FreebaseAPI::Session.new(:key => "GOOGLE_API_KEY", :env => :sandbox, :query_options => { :lang => :fr, :limit => 1 }) }

  it "should include HTTParty" do
    FreebaseAPI::Session.should include(HTTParty)
  end

  describe "#key" do
    context "when key has been set manually" do
      it "should return the API key" do
        dummy_session.key.should == 'GOOGLE_API_KEY'
      end
    end

    context "with the env variables defined" do
      before { ENV['GOOGLE_API_KEY'] = 'ENV_GOOGLE_API_KEY' }
      it "should return the API key" do
        session.key.should == 'ENV_GOOGLE_API_KEY'
      end
      after { ENV['GOOGLE_API_KEY'] = nil }
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

  describe "#image" do
    let(:request) {
      session.image('/en/bob_dylan')
    }

    context "when the query is successful" do
      it "should not raise any error" do
        expect {
          request
        }.to_not raise_error(FreebaseAPI::Error)
      end

      it "should return some data" do
        request.size.should > 1000
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

  describe "#search" do
    let(:request) {
      session.search('bob dylan')
    }

    context "when the query is successful" do
      it "should not raise any error" do
        expect {
          request
        }.to_not raise_error(FreebaseAPI::Error)
      end

      it "should return some topics" do
        request.should_not be_empty
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