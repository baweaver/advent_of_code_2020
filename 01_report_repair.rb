# Give a name to the idea of not finding a number, but make it compatible with
# the output functions to not crash on error
NOT_FOUND = [-1, -1]

# Inputs will be an array, and we're targeting two numbers which add up
# to 2020
def duals(input, target: 2020)
  # So we transform our input into ints, and bring along a hash for the ride
  input.map(&:to_i).each_with_object({}) do |v, duals|
    # Why? Well let's skip this line for a second and look at the next
    return [v, duals[v]] if duals[v]

    # We want a mapping of what number we need to pair `v` with to get to
    # 2020, so we use some algebra to say `2020 - v` to find it!
    #
    # That means with a value of `1020` our hash starts to look like
    # `{ 1000 => 1020}`. If `1000` happens to come along, great! We found
    # its partner and we can return it and `v` like above!
    duals[target - v] = v
  end

  # Otherwise we return back our idea of "not found"
  NOT_FOUND
end

# But wait, the problem spec wants those two numbers multiplied! Well let's see
# a few Ruby 3.0 tricks real quick:
#
# ## Argument Forwarding: `...` forwards all arguments
#
# Annoyingly this won't work with argument names at all. Will cover this later
# in the post, but no dice in my experiments. May submit some bugs or check
# on this one
#
# ## Endless Methods: Have a short method? This is valid!
#
# `def name() = value` is now valid, but mind your parens, we need those! That
# includes no-arg functions. I'd treat these as pure functions for sanity, and
# most certainly not as Python.
def product_duals(...) = duals(...).reduce(:*)

# Now a few more fun ones.
#
# Ruby 2.x introduced `yield_self` and `then` as an inverse of `tap`. It yields
# itself into the block like `tap` but returns whatever the block function
# returns instead.
#
# In this case we have a 2.7/3.0 feature in numbered params. `_1` is the implied
# value yielded to the block. If it gets more than one you have `_2` and so on.
#
# Then we `puts` the output for `STDOUT` and done~!
File.readlines(ARGV[0]).then { puts product_duals(_1) }
