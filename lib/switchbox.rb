class SwitchBox
  def initialize(vars={}, &block)
    @conditions = {}
    @results = {}
    @actions = []
    vars.each {|name,val| instance_variable_set(:"@#{name}", val)}
    
    if block_given?
      instance_eval(&block)
      go
    end
  end
  
  def condition(name, *cond_list, &block)
    if block_given?
      @conditions[name] = block
      @results[name] = nil
      @conditions[:"not_#{name}"] = lambda { !self[name] }
    else
      @conditions[name] = lambda { cond_list.all?{|cond| self[cond] } }
    end
  end
  
  def action(*conditions, &block)
    @actions << [lambda{ conditions.all?{|cond| self[cond]} }, block]
  end
  
  def [](name)
    raise ArgumentError, "condition '#{name}' not set" if @conditions[name].nil?
    return @results[name] unless @results[name].nil?
    @results[name] = !!@conditions[name].call
  end
  
  def go
    action = @actions.find {|conds,act| conds.call }
    action.last.call if action
  end
end

