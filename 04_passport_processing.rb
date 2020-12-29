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

# North pole doesn't care about CID so we can drop it with `except`, imported
# fresh from Rails to Ruby 3.0
VALID_NORTH_POLE_MAP = VALID_KEYS_MAP.except(:cid)

def valid_passports(passports)
  passports.filter_map do |passport|
    parsed_passport = passport
      # Split only cares about whitespace whether that be a space or a newline,
      # which is real handy for this problem
      .split
      # `to_h` takes a block, it's your new `map.to_h`.
      .to_h { _1.split(':') }
      # We're still doing some shenanigans with symbolizing keys here for a
      # pattern match demo later
      .transform_keys(&:to_sym)

    # So we can
    parsed_passport if parsed_passport in VALID_NORTH_POLE_MAP
  end
end

# Same one-line method trick as before to wrap over the full output
def valid_passport_count(...) = valid_passports(...).size

# This one is a bit different. At least they were nice enough to give us one
# clearly blank line between records which makes this much much easier.
File.read(ARGV[0]).split(/\n\n/).then { puts valid_passport_count(_1) }
