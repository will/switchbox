require 'lib/switchbox'

params = {:edit => false}
class FakeAR; attr_accessor :save end
record = FakeAR.new
record.save = true

SwitchBox.new do
  condition :combination => [:new, :not_edit, :yes]
  condition(:new)  { true }
  condition(:edit) { params[:edit] }
  condition(:yes)  { true }
  condition(:save) { record.save }
  
  action(:combination)       { puts "a combination yay!"}
  action(:save, :edit, :yes) { puts "edit yes!"}
end

@record = FakeAR.new
@record.save = true
def render(string); puts string end

a = SwitchBox.new
a.condition(:save) {@record.save}
a.action(:save) { render "saved! spectacular!" }
a.action(:not_save) { render "didn't save! radical!"}
a.go

SwitchBox.new(:record => @record) do
  condition(:save) {@record.save}
  action(:save) { render "saved! awesome!" }
  action(:not_save) { render "didn't save! cowabunga!"}
end