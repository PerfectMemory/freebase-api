require 'spec_helper'

describe FreebaseAPI::Attribute do

  let(:data) {
    {
    "text" => "Github",
    "lang" => "en",
    "value" => "Github ()",
    "creator" => "/user/mwcl_wikipedia_en",
    "timestamp" => "2008-08-18T10:47:44.000Z"
    }
  }

  let(:attribute) { FreebaseAPI::Attribute.new(data, :type => "string") }

  describe "#value" do
    it "should return the 'value' value" do
      attribute.value.should == "Github ()"
    end
  end

  describe "#text" do
    it "should return the 'text' value" do
      attribute.text.should == "Github"
    end
  end

  describe "#lang" do
    it "should return the 'lang' value" do
      attribute.lang.should == "en"
    end
  end

  describe "#type" do
    it "should return the attribute type" do
      attribute.type.should == "string"
    end
  end


end