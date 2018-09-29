require_relative "extends.rb"
require_relative "what.rb"
require_relative "predicates.rb"

include Predicates

# Various words
Predicates.create_adjective(:smallest) { Array.new.method(:min) }
Predicates.create_adjective(:largest) { Array.new.method(:max) }
Predicates.create_identity(:of)
Predicates.create_identity(:the)
