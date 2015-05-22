require_relative 'spec_helper'
require_relative 'square'

RSpec.describe Square do
  describe "#value" do
    it { Square.new(4.0).value.should == 2.0 }
    it { Square.new(10.0).value.should == 3.162277660168379 }
    it { Square.new(1001.0).value.should == 31.63858403911275 }
    it { Square.new(1008751.0).value.should == 1004.3659691566615 }
  end
end