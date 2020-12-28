# Oi, this one was a bit pesky to understand and I had to read it a few times.

# Granted I have a preference for x, y coordinate order. These will be the
# defaults but easy enough to make it configurable later if the problem
# specs should change.
SLOPE = [3, 1]
SLOPE_X, SLOPE_Y = SLOPE

# So we remember the symbols, also for comparisons later
TREE = '#'.freeze
CLEAR = '.'.freeze

CPU_COUNT = 4
workers = CPU_COUNT.times.map do
  Fiber.new do
    loop do
      message = Ractor.receive
      y, slope_x, map_line = message
      map_boundary = map_line.size - 1

      position = (y * slope_x) % map_boundary

      Ractor.yield map_line[position] == TREE ? 1 : 0
    end
  end
end

def collision_count(map, slope_x: SLOPE_X, slope_y: SLOPE_Y)
  # The thing about it going infinitely rightward is we can just
  # modulo our current position to realign it back to the map.
  #
  # What's modulo? Think of it as the remainder after division, or exactly how
  # many times we went past the last map segment. `11 % 10 == 1`, and
  # `13 % 10 == 3`, but remember that `25 % 10 == 5` because it cleanly divided
  # and `5` was the remainder, not `15`. We have subtraction for that.
  map_modulo = map.first.strip.size

  # Start with our initial position. Granted we don't _really_ need Y as
  # it's at one, and that'd change a lot more of this script if that changed,
  # so we'll just track it for now
  pos_x, pos_y = 0, 0

  # ...and away we go! Skip the first clean line
  map[1..-1].reduce(0) do |trees_hit, line|
    # Get our new X and Y position
    pos_x, pos_y = pos_x + slope_x, pos_y + slope_y

    # ...and where we are relative to the map extensions
    relative_x = pos_x % map_modulo

    # If we clocked a tree, register a new hit, otherwise return the current
    # count.
    line[relative_x] == TREE ? trees_hit + 1 : trees_hit
  end
end

# Hello `readlines` my old friend, I've come to call on you again because
# a problem softly ARGVing... ah, right. These lines won't change much
# on any of these problems.
File.readlines(ARGV[0]).then { puts collision_count(_1) }
