SwitchBox
=========

Will Leinweber – [blog](http://bitfission.com)

About
-----

SwitchBox lets you declare simple conditions and combine them into more complex conditions. These are used to decide which action to run.

The upshot is that messy if/elsif/else blocks are no longer necessary. All conditions are lazily evaluated and will only be ran once.

Conditions
----------

Conditions have a name and a block. They are only run when checking for which action to call, and their result is cached and only ran once. The block doesn't necessarily have to evaluate a boolean, but SwitchBox forces the result into a boolean value before caching.

    record = some_active_record_object
    
    box = SwitchBox.new
    box.condition(:saved) { record.save }

In this example, a condition named "saved" is created. Behind-the-scenes, you also get a "not_saved" condition.

Actions
-------

Actions are stored in the order they're declared, and the very first action to meet all of its conditions will be executed, and no others.

    # ... continuing from the above code
    box.action(:saved)     { render :text => "the record was saved!" }
    box.action(:not_saved) { render :text => "there was a problem" }
    box.go # will result in calling the first block
    
SwitchBox#go will look at the conditions for each action, and run appropriate action.

Alternate syntax
----------------

The above syntax is nice because you can pass the box around as needed, but for simple things, you can just do it all in one block

    SwitchBox.new do
      condition(:always_true) { true }
      action(:always_true) { puts "always printed" }
    end
    
In this case you don't need to call #go, it gets called at the end of the block.
      