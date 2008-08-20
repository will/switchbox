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
  
  def condition(name, &block)
    if block_given?
      @conditions[name] = block
      @results[name] = nil
      @conditions[:"not_#{name}"] = lambda { !self[name] }
    else
      name.each_pair do |new_cond, depedants|
        @conditions[new_cond] = lambda { depedants.all?{ |cond| self[cond] } }
      end
    end
  end
  
  def action(*conditions, &block)
    @actions << action_item( conditions, block )
  end
  
  def prepend_action(*conditions, &block)
    @actions.unshift action_item( conditions, block )
  end
  
  def [](name)
    raise ArgumentError, "condition '#{name}' not declared" if @conditions[name].nil?
    return @results[name] unless @results[name].nil?
    @results[name] = !!@conditions[name].call
  end
  
  def go
    action = @actions.find {|conds,act| conds.call }
    action.last.call if action
  end
  
  private
  def action_item(*args)
    action = args.pop
    conditions = args.flatten
    [ lambda{ conditions.all? { |cond| self[cond] } }, action ]
  end
end

