require File.join(File.dirname(__FILE__), 'spec_helper')

describe Slither::Generator do
  let(:optional) { false }

  context "when trailing newline is not needed based on the definition" do
    before(:each) do
      @definition = Slither.define :test do |d|
        d.header :optional => optional  do |h|
          h.trap { |line| line[0,4] == 'HEAD' }
          h.column :type, 4
          h.column :file_id, 10
        end
        d.body :optional => optional do |b|
          b.trap { |line| line[0,4] =~ /[^(HEAD|FOOT)]/ }
          b.column :first, 10
          b.column :last, 10
        end
        d.footer do |f|
          f.trap { |line| line[0,4] == 'FOOT' }
          f.column :type, 4
          f.column :file_id, 10
        end
      end
      @data = {
        :header => [ {:type => "HEAD", :file_id => "1" }],
        :body => [
          {:first => "Paul", :last => "Hewson" },
          {:first => "Dave", :last => "Evans" }
        ],
        :footer => [ {:type => "FOOT", :file_id => "1" }]
      }
      @generator = Slither::Generator.new(@definition)
    end

    context "when body and header are required" do
      it "should raise an error if there is no data for a required section" do
        @data.delete :header
        lambda { @generator.generate(@data) }.should raise_error(Slither::RequiredSectionEmptyError, "Required section 'header' was empty.")
      end

      it "should raise an error if the data is empty for a required section" do
        @data[:body] = []
        lambda { @generator.generate(@data) }.should raise_error(Slither::RequiredSectionEmptyError, "Required section 'body' was empty.")
      end
    end

    context "when body and header are optional" do
      let(:optional) { true }
      it "should not raise an error if there is no data for a required section" do
        @data.delete :header
        lambda { @generator.generate(@data) }.should_not raise_error
      end

      it "should not raise an error if the data is empty for a required section" do
        @data[:body] = []
        lambda { @generator.generate(@data) }.should_not raise_error
      end
    end

    it "should generate a string without a trailing newline" do
      expected = "HEAD         1\n      Paul    Hewson\n      Dave     Evans\nFOOT         1"
      @generator.generate(@data).should == expected
    end

    context "but needed based on the generator" do
      before(:each) do
        @generator = Slither::Generator.new(@definition, true)
      end

      it "should generate a string with a trailing newline" do
        expected = "HEAD         1\n      Paul    Hewson\n      Dave     Evans\nFOOT         1\n"
        @generator.generate(@data).should == expected
      end
    end

    context "when content is not an array but enumerable" do
      class CustomEnumerable
        include Enumerable

        RECORD = {:first => "Paul", :last => "Hewson" }

        def each
          3.times do
            yield RECORD
          end
        end
      end

      it "should generate expected output" do
        @data[:body] = CustomEnumerable.new
        expected = "HEAD         1\n      Paul    Hewson\n      Paul    Hewson\n      Paul    Hewson\nFOOT         1"
        @generator.generate(@data).should == expected
      end
    end

    context "when content is hash" do
      it "should generate expected output" do
        @data[:body] = {:first => "Paul", :last => "Hewson" }
        expected = "HEAD         1\n      Paul    Hewson\nFOOT         1"
        @generator.generate(@data).should == expected
      end
    end
  end

  context "when trailing newline is needed based on the definition" do
    before(:each) do
      @definition = Slither.define :test, trailing_newline: true do |d|
        d.header do |h|
          h.trap { |line| line[0,4] == 'HEAD' }
          h.column :type, 4
          h.column :file_id, 10
        end
        d.body do |b|
          b.trap { |line| line[0,4] =~ /[^(HEAD|FOOT)]/ }
          b.column :first, 10
          b.column :last, 10
        end
        d.footer do |f|
          f.trap { |line| line[0,4] == 'FOOT' }
          f.column :type, 4
          f.column :file_id, 10
        end
      end
      @data = {
        :header => [ {:type => "HEAD", :file_id => "1" }],
        :body => [
          {:first => "Paul", :last => "Hewson" },
          {:first => "Dave", :last => "Evans" }
        ],
        :footer => [ {:type => "FOOT", :file_id => "1" }]
      }
      @generator = Slither::Generator.new(@definition)
    end

    it "should generate a string with a trailing newline" do
      expected = "HEAD         1\n      Paul    Hewson\n      Dave     Evans\nFOOT         1\n"
      @generator.generate(@data).should == expected
    end

    context "and needed based on the generator" do
      before(:each) do
        @generator = Slither::Generator.new(@definition, true)
      end

      it "should generate a string with a trailing newline" do
        expected = "HEAD         1\n      Paul    Hewson\n      Dave     Evans\nFOOT         1\n"
        @generator.generate(@data).should == expected
      end
    end
  end
end
