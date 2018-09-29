# TODO: make this into an actual side project. Architect is more. Random goals:
# Make it look more like an AI
# Be able to parse real sentences and map them to these questions
# Add a billion new words and an interface to create new words
#   interface for creating new words:
#   type (boolean, etc)
#   method to call (as symbol, ie `:include?`)
# Figure out where functions should actually be defined
# Classify words: 
#   current idea: measures (middle words), ends, identities
# middle words should return values, end words should return answers. 
# that is:
# (largest? [1,2,3]).call 2 -> false (2 is not the largest)
# (largest [1,2,3]).call 2 -> 3 (val of 2 is ignored? hmm)
# is this possible?
#
# current vocab:
# TODO: figure out logic for boolean stuff again

module Predicates
  # Sentence-ends
  def true?
    lambda do |val|
      {:argument => true, :value => val, :result => true}
    end
  end

  def false?
    lambda do |val|
      {:argument => false, :value => val, :result => false}
    end
  end

  def this?(arg)
    lambda do |val|
      {:argument => arg, :value => val, :result => arg}
    end
  end

  def in?(arg)
    lambda do |val|
      {:argument => arg, :value => val, 
        :result => if (arg.methods.include?(:include?)) then arg.include?(val) else false end }
    end
  end

  def largest?(arg)
    lambda do |val| 
      {:argument => arg, :value => val, 
        :result => if (arg.methods.include?(:max)) then arg.max == val else false end }
    end
  end

  def smallest?(arg)
    lambda do |val| 
      {:argument => arg, :value => val, 
        :result => if (arg.methods.include?(:min)) then arg.min == val else false end }
    end
  end

  # Sentence-middles

  def nt(previous) 
    lambda do |val| 
      previous = previous.call val
      if previous[:result]
        {:argument => previous[:argument], :value => val, :result => !previous[:result]}
      else
        {:argument => previous[:argument], :value => val, :result => true}
      end
    end
  rescue ArgumentError, TypeError, NoMethodError => e
    raise e
  end

  def inn(previous) 
    lambda do |val| 
      previous = previous.call val
      if previous[:result]
        {:argument => previous[:argument], :value => val, :result => if (previous[:argument].methods.include?(:include?)) then previous[:argument].include?(val) else false end }
      else
        {:argument => previous[:argument], :value => val, :result => false}
      end
    end
  rescue ArgumentError, TypeError, NoMethodError => e
    raise e
  end

  def identity(previous) 
    lambda do |val| 
      previous = previous.call val
      if previous[:result]
        {:argument => previous[:argument], :value => val, :result => previous[:result] }
      else
        {:argument => previous[:argument], :value => val, :result => false}
      end
    end
  rescue ArgumentError, TypeError, NoMethodError => e
    raise e
  end

  private
  
  def self.create_alias(old_name, new_name)
    alias_method new_name, old_name
  end

  def self.create_identity(name)
    alias_method name, :identity
  end

  def self.create_adjective(word, &meaning)
    if block_given? && !self.methods.include?(word)
      begin
        type = meaning.call.class
      rescue NoMethodError
        type = NilClass
      end
      
      if type == Method
        def body(meth, previous)
          lambda do |val|
            previous = previous.call val
            meth = meth.call
            if previous[:result]
              {:argument => previous[:argument], :value => val, :result => meth.unbind.bind(previous[:argument]).call }
            else
              {:argument => previous[:argument], :value => val, :result => false}
            end
          end
        rescue ArgumentError, TypeError, NoMethodError => e
          raise e
        end
      
        define_method(word, lambda(&method(:body).curry[meaning]))
        true
      else
        def body(meth, previous)
          lambda do |val|
            previous = previous.call val
            if previous[:result]
              {:argument => previous[:argument], :value => val, :result => meth.call(previous[:argument]) }
            else
              {:argument => previous[:argument], :value => val, :result => false}
            end
          end
        rescue ArgumentError, TypeError, NoMethodError => e
          raise e
        end
      
        define_method(word, lambda(&method(:body).curry[meaning]))
        true
      end
    else
      false
    end
  end
  
  # note that ints are true, so while things work (with if previous[:result], eg)
  # not working how you think.

  # # BUG: 
  # false.is inn this? [] #=> true
  # >> false.is inn this? [nil] #=> true
  # >> false.is inn this? [1] #=> true
  # >> false.is inn this? [1,2,3] #=> true
  # Weirdly you cant call more than once, like
  # m.call
  # m.call
end
