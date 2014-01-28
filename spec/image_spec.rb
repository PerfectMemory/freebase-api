require 'spec_helper'
require 'tempfile'

describe FreebaseAPI::Image do

  let(:options) { { :maxheight => 20, :maxwidth => 20 } }
  let(:image) { FreebaseAPI::Image.get('/en/bob_dylan', options) }

  let(:data) {
    load_data 'img.jpg'
  }

  before {
    stubbed_session = mock('session')
    FreebaseAPI.stub(:session).and_return(stubbed_session)
    stubbed_session.stub(:image).and_return(data)
  }

  describe ".get" do
    let(:stubbed_session) { mock('session').as_null_object }

    before {
      FreebaseAPI.stub(:session).and_return(stubbed_session)
    }

    it "should make a Image API call" do
      stubbed_session.should_receive(:image).with('/en/bob_dylan', :maxheight => 20, :maxwidth => 20).and_return(data)
      image
    end

    it "should return an image" do
      image.should be_kind_of FreebaseAPI::Image
    end
  end

  describe "#id" do
    it "should return the topic related ID" do
      image.id.should == '/en/bob_dylan'
    end
  end

  describe "#size" do
    it "should return the image size" do
      image.size.should == data.size
    end
  end

  describe "#store" do
    it "should store the image" do
      Dir::Tmpname.create 'freebase-api' do |file|
        image.store(file)
        File.size(file).should == data.size
        File.unlink(file)
      end
    end
  end
end