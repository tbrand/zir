require "../spec_helper"

Dir.cd "spec/projs/p0" do
  describe Zir::Engine do

    code0 = <<-CODE0
<-%rb0 a = 4 ->
<-%rb0 a.times do |a| ->
<-@rb0     puts "int a\#{a} = \#{a};"->
<-%rb0 end ->
CODE0

    code1 = <<-CODE1
<-%rb0 a = 100 ->
<-%rb1 b = 101 ->
<-@rb0 puts "int a = \#{a};" ->
<-@rb1 puts "int b = \#{b};" ->
CODE1

    it "#scan_code code0" do
      engine = Zir::Engine.new(code0)
      engine.scan_code

      hex = engine.hex

      engine.macros.each_with_index do |m, i|
        m.idx.should eq(i)
        m.id.should eq("rb0")
        m.mark.should eq("__#{hex}_#{m.idx}__")
      end
    end

    it "#scan_code code1" do
      engine = Zir::Engine.new(code1)
      engine.scan_code
      
      hex = engine.hex

      engine.macros.each_with_index do |m, i|
        m.idx.should eq(i)
        m.id.should eq(i%2 == 0 ? "rb0" : "rb1")
        m.mark.should eq("__#{hex}_#{m.idx}__")
      end
    end

    it "#scan_id_group code0" do
      engine = Zir::Engine.new(code0)
      engine.scan_code
      engine.scan_id_group
      engine.clean

      engine.macros[0].filepath.should eq(nil)
      engine.macros[1].filepath.should eq(nil)
      engine.macros[2].filepath.should eq("#{Dir.current}/.zir/__#{engine.hex}_2__")
      engine.macros[3].filepath.should eq(nil)
    end

    it "#scan_id_group code1" do
      engine = Zir::Engine.new(code1)
      engine.scan_code
      engine.scan_id_group
      engine.clean

      engine.macros[0].filepath.should eq(nil)
      engine.macros[1].filepath.should eq(nil)
      engine.macros[2].filepath.should eq("#{Dir.current}/.zir/__#{engine.hex}_2__")
      engine.macros[3].filepath.should eq("#{Dir.current}/.zir/__#{engine.hex}_3__")
    end

    it "exec_macro code0" do
      engine = Zir::Engine.new(code0)
      engine.scan_code
      engine.scan_id_group
      engine.exec_macro
      engine.clean

      engine.macros[0].result.should eq(nil)
      engine.macros[1].result.should eq(nil)
      engine.macros[2].result.should eq("int a0 = 0;\nint a1 = 1;\nint a2 = 2;\nint a3 = 3;")
      engine.macros[3].result.should eq(nil)
    end

    it "exec_macro code1" do
      engine = Zir::Engine.new(code1)
      engine.scan_code
      engine.scan_id_group
      engine.exec_macro
      engine.clean

      engine.macros[0].result.should eq(nil)
      engine.macros[1].result.should eq(nil)
      engine.macros[2].result.should eq("int a = 100;")
      engine.macros[3].result.should eq("int b = 101;")
    end

    it "#run code0" do
      engine = Zir::Engine.new(code0)
      engine.run
      engine.clean
      engine.code.should eq("\n\nint a0 = 0;\nint a1 = 1;\nint a2 = 2;\nint a3 = 3;\n")
    end

    it "#run code1" do
      engine = Zir::Engine.new(code1)
      engine.run
      engine.clean
      engine.code.should eq("\n\nint a = 100;\nint b = 101;")
    end
  end
end
