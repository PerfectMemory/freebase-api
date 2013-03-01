require 'spec_helper'

describe FreebaseAPI::Topic do

  let(:options) { { :lang => :en } }
  let(:topic) { FreebaseAPI::Topic.get('/en/github', options) }
  let(:new_topic) { FreebaseAPI::Topic.new('/en/github') }

  let(:data) {
    load_fixture 'topic'
  }

  before {
    stubbed_session = mock('session')
    FreebaseAPI.stub(:session).and_return(stubbed_session)
    stubbed_session.stub(:topic).and_return(data)
  }

  describe ".get" do
    let(:stubbed_session) { mock('session').as_null_object }

    before {
      FreebaseAPI::Topic.any_instance.stub(:build)
      FreebaseAPI.stub(:session).and_return(stubbed_session)
    }

    it "should make a Topic API call" do
      stubbed_session.should_receive(:topic).with('/en/github', :lang => :en, :filter => 'commons').and_return(data)
      topic
    end

    it "should return a topic" do
      topic.should be_kind_of FreebaseAPI::Topic
    end
  end

  describe "#id" do
    context "when the topic has been sync yet" do
      it "should return the topic ID" do
        new_topic.id.should == '/en/github'
      end
    end

    context "when the topic has been sync" do
      it "should return the topic ID" do
        topic.id.should == '/m/04g0kcw'
      end
    end
  end

  describe "#text" do
    it "should return the topic text" do
      topic.text.should == "GitHub"
    end
  end

  describe "#lang" do
    it "should return the topic language" do
      topic.lang.should == 'en'
    end
  end

  describe "#name" do
    it "should return the topic name" do
      topic.name.should == 'GitHub'
    end
  end

  describe "#types" do
    it "should return all the topic types" do
      topic.types.should == ["/common/topic", "/internet/website", "/base/technologyofdoing/proposal_agent"]
    end
  end

  describe "#description" do
    it "should return the topic description" do
      topic.description.should start_with "GitHub is a web-based hosting service for software development projects that use the Git revision control system."
    end
  end

  describe "#properties" do
    it "should return the properties values which are topics" do
      link = topic.properties['/internet/website/category'].first
      link.should be_kind_of(FreebaseAPI::Topic)
      link.name.should == 'Revision control'
    end

    it "should return the properties values which are data" do
      link = topic.properties['/common/topic/official_website'].first
      link.should be_kind_of(FreebaseAPI::Attribute)
      link.value.should == 'http://github.com/'
    end

    context "with a property exclusion constraint" do
      let(:topic) { FreebaseAPI::Topic.get('/en/github', :exclude => '/internet') }

      it "should not return these properties" do
        topic.properties.should_not have_key('/internet/website/category')
      end

      it "should return the properties that do not match this exclusion" do
        topic.properties.should have_key('/common/topic/official_website')
      end
    end
  end

  describe "#property" do
    it "should return the asked property" do
      property = topic.property('/type/object/type')
      property.should have(3).elements
    end
  end

  describe "#properties domains" do
    it "should return an hash containing the properties domains" do
      topic.properties_domains.should == { 'common' => 16, 'internet' => 1,'type' => 30 }
    end
  end
end