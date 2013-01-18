module FreebaseAPI
  # Helpers for Rspec
  module Helpers
    def load_fixture( fixture )
      JSON.parse(IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", "#{fixture}.json")))
    end
  end
end