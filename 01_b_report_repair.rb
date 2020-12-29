# This one I'm being quite lazy on
File.readlines(ARGV[0]).then do |input|
  puts input
    # First we need integers to work with
    .map(&:to_i)
    # We can make this into an Enumerator to make sure we don't
    # iterate every possible combination, just however many we
    # need to find what we want to find
    .to_enum(:combination, 3)
    # So we can literally find it by summing up the combinations,
    # a three item array, and see if it gets to 2020.
    #
    # Do note that you can only use numbered params one level deep, hence
    # `input` above.
    .find { _1.sum == 2020 }
    # Once you find that set of numbers, get its product and we're done!
    .reduce(1, :*)
end
