# I'm cheating a bit here. `any` is my gem which returns true for about anything
# you can do to it, notably `===`:
#
#   Any === 'any value here'
#
# ...because guess what pattern matching uses for value comparisons? Yep.
require 'any'

# We're doing the symbol thing again for one-line pattern matching demos
VALID_KEYS = %i(byr iyr eyr hgt hcl ecl pid cid)

# This is definitely cheating, but works, so...
VALID_KEYS_MAP = VALID_KEYS.to_h { |k| [k, Any] }

def valid_passports(passports)
  passports.filter_map do |passport|
    parsed_passport = passport
      # Split only cares about whitespace whether that be a space or a newline,
      # which is real handy for this problem
      .split
      # `to_h` takes a block, it's your new `map.to_h`.
      .to_h { |s| s.split(':') }
      # We're still doing some shenanigans with symbolizing keys here for a
      # pattern match demo later
      .transform_keys(&:to_sym)

    # Pattern matching does not like constants, this is likely a bug
    valid_keys_map = VALID_KEYS_MAP

    valid_north_pole = valid_keys_map.except(:cid)

    # Normally I would do this:
    #   parsed_passport.keys == valid_keys
    #
    # ..because this doesn't work: (constants break it too)
    #   parsed_passport in ^valid_keys
    #
    # But what does work is this:
    parsed_passport if parsed_passport in ^valid_keys_map | ^valid_north_pole

    # The `^` here makes sure `in` doesn't try and overwrite that hash and
    # return `true`. I think this is unintuitive, but could see why it works
    # that way given pattern matching in general. `^` "pins" a variable rather
    # than use it as an assignment in pattern matching.
    #
    # `|` in this case is an "or" condition
  end
end

# Same one-line method trick as before to wrap over the full output
def valid_passport_count(...) = valid_passports(...).size

# This one is a bit different. At least they were nice enough to give us one
# clearly blank line between records which makes this much much easier.
File.read(ARGV[0]).split(/\n\n/).then { puts valid_passport_count(_1) }
