class Object
  def is(block)
    result = block.call self
    result[:result] == self || result[:result] == true
  rescue ArgumentError, TypeError
    nil
  end
end

class TrueClass
  def is(block)
    result = block.call self
    result[:result] == self
  rescue ArgumentError, TypeError
    nil
  end
end

class FalseClass
  def is(block)
    result = block.call self
    result[:result] == self
  rescue ArgumentError, TypeError
    nil
  end
end

class NilClass
  def is(block)
    result = block.call self
    result[:result] == self || result[:result] == true
  rescue ArgumentError, TypeError
    nil
  end
end
