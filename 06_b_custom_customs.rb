def answer_intersection(answers) =
  answers
    # Each answer group is a series of answers on newlines
    .lines
    # We want to split them into characters and remove
    # newlines that'll throw our count
    .map { _1.chomp.chars }
    # There's a lot in this one statement. If we reduced an
    # array of ints with `+` we'd get this:
    #
    #   [1, 2, 3].reduce(:+) == 1 + 2 + 3
    #
    # So if we did that with intersection it'd be:
    #
    #   [[1,2,3], [2, 3], [2]].reduce(&:intersection) ==
    #     [1,2,3].intersection([2,3]).intersection([2]) ==
    #     [2]
    #
    # Yes, intersection can take multiple arrays, but that's
    # not what reduce does here. Without an initial value it
    # starts with the first element of the collection being
    # reduced:
    #
    #   numbers = [1, 2, 3]
    #   numbers.reduce(0, :+) # Starts with 0
    #   numbers.reduce(:+)    # Starts with 1
    #
    # ...and we can express all that in one line. Cool eh?
    .reduce(&:intersection)
    # Then we want to know how many elements intersected
    .size

puts File
  .read(ARGV[0])
  .split(/\n\n/)
  .map { answer_intersection(_1) }
  .sum
