# I like naming things to make them clearer
FRONT = 'F'.freeze
BACK  = 'B'.freeze
LEFT  = 'L'.freeze
RIGHT = 'R'.freeze

# This is a fun little trick. The problem spec hinted at it pretty hard
# with "binary boarding", meaning each character is a bit switch. First half
# for off, last half for on, convert and `to_i(2)` to get that lovely binary.
#
# Right, gsub with a hash, that's fun. We're substituting every character and
# a Hash can be coerced into a proc or in the case of gsub it looks for a value
# to substitute in the place of a key
def find_position(pass) = pass.gsub(/./, {
  FRONT => 0,
  LEFT  => 0,
  BACK  => 1,
  RIGHT => 1
}).to_i(2)

# Then we transform all our passes into their positions
def positions(passes) = passes.map { find_position(_1) }

# ...and find the largest position
def max_position(...) = positions(...).max

File.readlines(ARGV[0]).then { puts max_position(_1) }
