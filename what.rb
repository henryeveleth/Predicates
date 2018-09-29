class What
  def self.is(block)
    result = block.call self
    result[:result]
  rescue ArgumentError, TypeError
    nil
  end
end
