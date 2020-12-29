# Now this part gives me a good chance to show a lot more of pattern matching's
# power.

# I'm cheating a bit here. `any` is my gem which returns true for about anything
# you can do to it, notably `===`:
#
#   Any === 'any value here'
#
# ...because guess what pattern matching uses for value comparisons? Yep.
require 'any'

# Int representation of string in a range
str_int_within = -> range { -> v { range.cover? v.to_i } }

HEIGHT_REGEX          = /(?<n>\d+) ?(?<units>cm|in)/
HAIR_COLOR_REGEX      = /^\#[0-9a-z]{6}$/
PASSPORT_ID_REGEX     = /^[0-9]{9}$/
EYE_COLOR_REGEX       = Regexp.union(*%w(amb blu brn gry grn hzl oth))
VALID_BIRTH_YEAR      = str_int_within[1920..2002]
VALID_ISSUED_YEAR     = str_int_within[2010..2020]
VALID_EXPIRATION_YEAR = str_int_within[2020..2030]
VALID_CM_HEIGHT       = str_int_within[150..193]
VALID_IN_HEIGHT       = str_int_within[59..76]

# Demonstrating proc composition
VALID_HEIGHT =
  -> { HEIGHT_REGEX.match(_1) } >>
  # If there's no match it's `nil`, meaning we need to use
  # the lonely (`&.`) operator to let it pass through
  -> { _1&.named_captures } >>
  # Transform the keys to symbols again for pattern matching
  -> { _1&.transform_keys(&:to_sym) } >>
  # This is the same trick with `Any`: { key: Any} is always true for
  # a match
  -> {
    case _1
    # Note you can't use inline proc calls here, I've tried, hence
    # the constant instead. This relies on `Proc#===` being `call` to
    # work.
    in units: 'cm', n: VALID_CM_HEIGHT
      Any
    in units: 'in', n: VALID_IN_HEIGHT
      Any
    else
      nil
    end
  }

def valid_passports(passports)
  passports.filter_map do |passport|
    parsed_passport =
      passport.split.to_h { |s| s.split(':') }.transform_keys(&:to_sym)

    parsed_passport if parsed_passport in {
      byr: VALID_BIRTH_YEAR,
      iyr: VALID_ISSUED_YEAR,
      eyr: VALID_EXPIRATION_YEAR,
      hgt: VALID_HEIGHT,
      hcl: HAIR_COLOR_REGEX,
      ecl: EYE_COLOR_REGEX,
      pid: PASSPORT_ID_REGEX
    }
  end
end

# Same one-line method trick as before to wrap over the full output
def valid_passport_count(...) = valid_passports(...).size

# This one is a bit different. At least they were nice enough to give us one
# clearly blank line between records which makes this much much easier.
File.read(ARGV[0]).split(/\n\n/).then { puts valid_passport_count(_1) }
