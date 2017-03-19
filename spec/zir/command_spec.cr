require "../spec_helper"

include Zir::Executor

describe Zir::Executor do

  it "cmd_exec" do
    cmd_exec("echo 0").should eq("0")
  end
end
