require "../spec_helper"
require "yaml"

class ParserForSpec
  include Zir::Parser
end

source_yaml_p0 = <<-SOURCE_YAML_P0
targets:
  - test.c.z

ids:
  rb0: ruby @file
  rb1: ruby @file

finally: gcc test.c -o test
SOURCE_YAML_P0

source_yaml_p1 = <<-SOURCE_YAML_P1
targets:
  - test*.c.z

ids:
  ruby: ruby @file
  python: python @file

finally:
  make
SOURCE_YAML_P1

Dir.cd "spec/projs/p0" do

  describe Zir::Parser do

    it "yaml_path" do
      parser = ParserForSpec.new
      parser.yaml_path.should eq("#{Dir.current}/zir.yaml")
    end

    it "yaml" do
      parser = ParserForSpec.new
      y0 = YAML.parse(source_yaml_p0)
      y1 = parser.yaml
      y0.should eq(y1)
    end

    it "get_cmd" do
      parser = ParserForSpec.new
      parser.get_cmd("rb0").should eq("ruby @file")
      parser.get_cmd("rb1").should eq("ruby @file")
    end

    it "get_targets" do
      parser = ParserForSpec.new
      targets = parser.get_targets
      targets.size.should eq(1)
      targets[0].should eq(File.expand_path("test.c.z"))
    end

    it "get_finally" do
      parser = ParserForSpec.new
      parser.get_finally.should eq("gcc test.c -o test")
    end
  end
end

Dir.cd "spec/projs/p1" do

  describe Zir::Parser do

    it "yaml_path" do
      parser = ParserForSpec.new
      parser.yaml_path.should eq("#{Dir.current}/zir.yaml")
    end

    it "yaml" do
      parser = ParserForSpec.new
      
      y0 = YAML.parse(source_yaml_p1)
      y1 = parser.yaml
      y0.should eq(y1)
    end

    it "get_cmd" do
      parser = ParserForSpec.new
      parser.get_cmd("ruby").should eq("ruby @file")
      parser.get_cmd("python").should eq("python @file")
    end

    it "get_targets" do
      parser = ParserForSpec.new
      targets = parser.get_targets
      targets.size.should eq(2)
      targets[0].should eq(File.expand_path("test0.c.z"))
      targets[1].should eq(File.expand_path("test1.c.z"))
    end

    it "get_finally" do
      parser = ParserForSpec.new
      parser.get_finally.should eq("make")
    end
  end
end
