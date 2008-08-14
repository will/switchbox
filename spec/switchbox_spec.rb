require 'rubygems'
require 'spec'
require "lib/switchbox"

describe SwitchBox, "conditions" do
  before do
    @box = SwitchBox.new
  end
  
  it "should be able to add new conditions" do
    proc { @box.condition(:dont_break) { true } }.should_not raise_error
  end
  
  it "should be able to find the result of a condition" do
    @box.condition(:new_cond) { true }
    @box[:new_cond].should be_true
  end
  
  it "should make not_* conditions with the opposite logic" do
    @box.condition(:cond) { true }
    @box[:not_cond].should be_false
  end
  
  it "should be able to combine conditions" do
    @box.condition(:cond_1) { true }
    @box.condition(:cond_2) { false }
    @box.condition :combo => [:cond_1, :cond_2]
    @box[:combo].should be_false
  end
  
  it "should be able to overwrite old conditions" do
    @box.condition(:cond) { true }
    @box[:cond].should be_true
    @box.condition(:cond) { false }
    @box[:cond].should be_false
  end
  
  it "should raise an argument error if asked for a condition that has not been declared" do
    lambda { @box[:not_declared] }.should raise_error(ArgumentError)
  end
  
  describe "should only evaluate things once, and save the result" do
    before do
      @pineapple = mock "pinapple"
      @box.condition(:cond) { @pineapple.test? }
    end
    
    after do
      @box[:cond]
      @box[:cond]
    end
    
    it "when the result is true" do
      @pineapple.should_receive(:test?).once.and_return(true)
    end
    
    it "when the result is false" do
      @pineapple.should_receive(:test?).once.and_return(false)
    end
    
    it "when the result is nil" do
      @pineapple.should_receive(:test?).once.and_return(nil)
    end
    
    it "when the result is something else" do
      @pineapple.should_receive(:test?).once.and_return(3)
    end
    
    it "even when using the not_* conditions" do
      @pineapple.should_receive(:test?).once
      @box[:not_cond]
    end
  end
end

describe SwitchBox, "actions" do
  before do
    @box = SwitchBox.new
    @box.condition(:true_cond) { true }
    @box.condition(:true_cond_2) { true }
    @box.condition(:false_cond) { false }
    @mango = mock "mango"
  end
  
  after do
    @box.go
  end
  
  it "should run the action if the condition is true" do
    @box.action(:true_cond) { @mango.action }
    @mango.should_receive(:action).once
  end
  
  it "should not run the action of the condition is false" do
    @box.action(:false_cond) { @mango.action }
    @mango.should_not_receive(:action)
  end
  
  it "should be able to check multiple conditions" do
    @box.action(:true_cond, :true_cond_2) { @mango.action }
    @mango.should_receive(:action).once
  end
  
  it "should only run the action if all conditions are true" do
    @box.action(:true_cond, :false_cond, :true_cond_2) { @mango.action }
    @mango.should_not_receive(:action)
  end
  
  it "should only run the first action that is true" do
    @box.action(:false_cond)  { @mango.not_action }
    @box.action(:true_cond)   { @mango.action }
    @box.action(:true_cond_2) { @mango.not_action_2 }
    
    @mango.should_receive     :action
    @mango.should_not_receive :not_action
    @mango.should_not_receive :not_action_2
  end
end

describe SwitchBox, "#new" do
  it "should allow declarations in the new block and run everything at the end" do
    orange = mock "orange"
    orange.should_receive(:action).once
    
    SwitchBox.new do
      condition(:cond) { true }
      action(:cond) { orange.action }
    end
  end
  
  it "should let you pass in instance variables as locals" do
    @orange = mock "orange"
    @orange.should_receive(:action).once
    
    SwitchBox.new(:orange2 => @orange) do
      condition(:cond) { true }
      action(:cond) { @orange2.action }
    end
  end
end