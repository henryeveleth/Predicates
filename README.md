# Predicates

Fun little ruby library that abuses lambdas and meta-programming.

## Usage

With Predicates, you can ask questions in Ruby. 

You can ask for a boolean:
```
2.is largest of this? [1,2,3] #=> false
```

Or for a value directly, using the `What` class:
```
What.is largest of this? [1,2,3,4,5] #=> 1
```

Beyond just asking questions, though, you can define your own words. Note that you
can pass in a class's already defined method, or a proc.
```
Predicates.create_adjective(:miniest) { Array.new.method(:min) } #=> true
Predicates.create_adjective(:two_times) { |x| x * 2 } #=> true

What.is miniest of this? [8,10,4,6] #=> 4
What.is two_times this? 5 #=> 10
What.is two_times this? "Hello" #=> "HelloHello"
```

If you try to ask a bad question, you'll get a nil:
```
What.is largest of this? "Hello" #=> nil
```

You can also alias words that already exist, and create 'no-op' (identity) words:
```
Predicates.create_alias(:does_not_exist,:see?) #=> false
Predicates.create_alias(:largest,:grandest) #=> true

What.is grandest of this? [1,2,3] #=> 3


Predicates.create_identity(:noop) #=> true
What.is noop noop noop grandest noop this? [5,6,7] #=> 7
```

#### Further Examples
```
(1 + 2 == 3).is true? #=> true
false.is in? [1,2,nil,"hello",true] #=> false
7.is inside this? ["abc",false,7] #=> true
10.is nt inside this? ["hello","world"] #=> true
```

#### Current Vocabulary

Defined in `words`.

## Bugs
- Questions on booleans
- What.is two_times two_times this? "Hello" #= "HelloHello"

## Future goals
- Be able to parse real sentences:
  - `"What is the minimum in [1,2,3]?"` -> `What.is smallest this? [1,2,3]`
- Add a billion new words
- Parse a .yml to make a vocabulary
- Add new ending words
