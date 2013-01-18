require 'spec_helper'

describe FreebaseAPI do

  it "should have a default logger" do
    FreebaseAPI.logger.should be_kind_of(Logger)
  end

  it "should have a default session" do
    FreebaseAPI.session.should be_kind_of(FreebaseAPI::Session)
  end

end