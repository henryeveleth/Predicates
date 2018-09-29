module Predicates
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

  def inside(previous) 
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
    if self.methods.include?(old_name) && !self.methods.include?(new_name)
      alias_method new_name, old_name
      true
    else
      false
    end
  end

  def self.create_identity(name)
    if !self.methods.include?(name)
      alias_method name, :identity
      true
    else
      false
    end
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
end
