# imported to handle any plural/singular conversions
require 'active_support/core_ext/string'

class ThingArray < Array
  def each(*_args, &block)
    to_a.each do |element|
      element.instance_eval(&block)
    end
  end
end

class IsHandler
  def initialize(thing, value)
    @thing = thing
    @value = value
  end

  def method_missing(m, *args, &block)
    @thing.append_property("#{m}?", @value)
  end
end

class HasHandler
  def initialize(thing, amount)
    @thing = thing
    @amount = amount
  end

  def method_missing(m, *args, &block)
    if @amount > 1
      belongings = ThingArray.new(@amount, Thing.new("#{m}".singularize))
      belongings.map{ |belonging| belonging.is_a.send("#{m}".singularize) }

      @thing.append_property(
        "#{m}", 
        belongings
      )
      
      return belongings
    else 
      belonging = Thing.new("#{m}")
      belonging.is_a.send("#{m}")

      @thing.append_property(
        "#{m}", 
        belonging
      )
      
      return belonging
    end
  end
end

class TitleHandler
  def initialize(thing:, title:)
    @thing = thing
    @title = title
  end
  
  def method_missing(m, *args, &block)
      @thing.append_property(@title, "#{m}")
  end
end

class IsTheHandler
  def initialize(thing)
    @thing = thing
  end
  
  def method_missing(m, *args, &block)
    TitleHandler.new(thing: @thing, title: "#{m}")
  end
end

class CharacteristicHandler
  def initialize(thing:, characteristic:)
    @thing = thing
    @characteristic = characteristic
  end
  
  def method_missing(m, *args, &block)
      @thing.append_property(@characteristic, "#{m}")

      @thing
  end
end

class BeingTheHandler
  def initialize(thing)
    @thing = thing
  end
  
  def method_missing(m, *args, &block)
    CharacteristicHandler.new(thing: @thing, characteristic: "#{m}")
  end
end

class CanHandler
  def initialize(thing)
    @thing = thing
  end

  def method_missing(m, *args, &block)
    logging_method_name = args.first
    @thing.define_singleton_method(m, logging_lambda(@thing, logging_method_name, &block))
  end

  def logging_lambda(thing, logging_method_name, &block)
    lambda do |arg|
      result = instance_exec arg, &block
      
      if logging_method_name
        current = thing.attributes[logging_method_name.to_sym] ||= []
        thing.append_property(logging_method_name, current + [result])
      end
      
      result
    end
  end
end

class Thing
  attr_accessor :attributes

  def initialize(name)
    @attributes = { name: name }
    
    self.set_properties(@attributes)
  end
  
  def set_properties(attributes = {})
    attributes.each do |attr, value|
      # Setter
      define_singleton_method("#{attr}=") { |val| attributes[attr] = val }
      # Getter
      define_singleton_method(attr) { attributes[attr.to_sym] }
    end
  end

  def is_a
    IsHandler.new(self, true)
  end

  def is_not_a
    IsHandler.new(self, false)
  end

  def append_property(property, value)
    @attributes.merge!({ property.to_sym => value })
    
    self.set_properties(@attributes)
  end

  def has(amount)
    HasHandler.new(self, amount)
  end
  
  def having(amount)
     self.has(amount)
  end
  
  def is_the
    IsTheHandler.new(self)
  end
  
  def being_the
    BeingTheHandler.new(self)
  end
  
  def and_the
    BeingTheHandler.new(self)
  end

  def can
    CanHandler.new(self)
  end
end