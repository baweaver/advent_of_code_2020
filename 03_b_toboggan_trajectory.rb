# Oi, this one was a bit pesky to understand and I had to read it a few times.

# Granted I have a preference for x, y coordinate order. These will be the
# defaults but easy enough to make it configurable later if the problem
# specs should change.
SLOPE = [3, 1]
SLOPE_X, SLOPE_Y = SLOPE

# So we remember the symbols, also for comparisons later
TREE = '#'
CLEAR = '.'

def collision_count(map, slope_x: SLOPE_X, slope_y: SLOPE_Y)
  # The thing about it going infinitely rightward is we can just
  # modulo our current position to realign it back to the map.
  #
  # What's modulo? Think of it as the remainder after division, or exactly how
  # many times we went past the last map segment. `11 % 10 == 1`, and
  # `13 % 10 == 3`, but remember that `25 % 10 == 5` because it cleanly divided
  # and `5` was the remainder, not `15`. We have subtraction for that.
  map_modulo = map.first.strip.size

  # Start with our initial position. Yep, now we need Y for the next part, this
  # gets more interesting.
  pos_x, pos_y = 0, 0

  # ...and away we go! Skip the first slope_y clean line(s), and abuse the fact
  # that ranges can help us deal with Y using `step`, or the 2.7 alias `%`.
  #
  # What's `step`? It lets us do this:
  #
  # `(1..10).step(2).to_a # => [1, 3, 5, 7, 9]`
  #
  # So we end up taking every nth element. Real handy some times
  map[(slope_y..map.size) % slope_y].reduce(0) do |trees_hit, line|
    # Get our new X and Y position
    pos_x, pos_y = pos_x + slope_x, pos_y + slope_y

    # ...and where we are relative to the map extensions
    relative_x = pos_x % map_modulo

    # If we clocked a tree, register a new hit, otherwise return the current
    # count.
    line[relative_x] == TREE ? trees_hit + 1 : trees_hit
  end
end

# We'll put all of our slope positions up here for now
POSITIONS = [
  { slope_x: 1, slope_y: 1 },
  { slope_x: 3, slope_y: 1 },
  { slope_x: 5, slope_y: 1 },
  { slope_x: 7, slope_y: 1 },
  { slope_x: 1, slope_y: 2 }
]

File.readlines(ARGV[0]).then do |map|
  # Then we can get all the counts
  puts POSITIONS
    # Double splat will put x and y in as kwargs
    .map { |pos| collision_count(map, **pos) }
    # Reduce here is getting the product with an initial value of 1
    .reduce(1, :*)

  # Wait, why `1`? Well you might see `reduce(0, :+)` on occasion. That's because
  # if you add `0` to any number you get that number, making it a great start.
  #
  # Same with `1` for multiplication. There are some fun rules here, but
  # that's a much longer post. Feel free to ask me later if you're curious.
end
