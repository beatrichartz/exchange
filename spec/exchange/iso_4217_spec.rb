require 'spec_helper'

describe "Exchange::ISO4217" do
  let(:subject) { Exchange::ISO4217 }
  describe "self.definitions" do
    it "should be a hash of definitions loaded from the yaml file" do
      subject.definitions.should == YAML.load_file('iso4217.yml')
    end
  end
  describe "self.instantiate" do
    it "should instantiate a big decimal according to the iso standards" do
      BigDecimal.should_receive(:new).with('23.23', 3).and_return('INSTANCE')
      subject.instantiate(23.23, 'TND').should == 'INSTANCE'
      BigDecimal.should_receive(:new).with('23.23', 2).and_return('INSTANCE')
      subject.instantiate(23.23, 'SAR').should == 'INSTANCE'
      BigDecimal.should_receive(:new).with('23.23', 0).and_return('INSTANCE')
      subject.instantiate(23.23, 'CLP').should == 'INSTANCE'
    end
  end
  describe "self.round" do
    it "should round a currency according to ISO 4217 Definitions" do
      subject.round(BigDecimal.new("23.232524"), 'TND').should == BigDecimal.new("23.233")
      subject.round(BigDecimal.new("23.232524"), 'SAR').should == BigDecimal.new("23.23")
      subject.round(BigDecimal.new("23.232524"), 'CLP').should == BigDecimal.new("23")
    end
  end
  describe "self.stringify" do
    it "should stringify a currency according to ISO 4217 Definitions" do
      subject.stringify(BigDecimal.new("23.232524"), 'TND').should == "TND 23.233"
      subject.stringify(BigDecimal.new("23.232524"), 'SAR').should == "SAR 23.23"
      subject.stringify(BigDecimal.new("23.232524"), 'CLP').should == "CLP 23"
      subject.stringify(BigDecimal.new("23.2"), 'TND').should == "TND 23.200"
      subject.stringify(BigDecimal.new("23.4"), 'SAR').should == "SAR 23.40"
      subject.stringify(BigDecimal.new("23.0"), 'CLP').should == "CLP 23"
    end
    it "should not render the currency if only the amount is wished for" do
      subject.stringify(BigDecimal.new("23.232524"), 'TND', :amount_only => true).should == "23.233"
      subject.stringify(BigDecimal.new("23.232524"), 'SAR', :amount_only => true).should == "23.23"
      subject.stringify(BigDecimal.new("23.232524"), 'CLP', :amount_only => true).should == "23"
      subject.stringify(BigDecimal.new("23.2"), 'TND', :amount_only => true).should == "23.200"
      subject.stringify(BigDecimal.new("23.4"), 'SAR', :amount_only => true).should == "23.40"
      subject.stringify(BigDecimal.new("23.0"), 'CLP', :amount_only => true).should == "23"
    end
  end
end