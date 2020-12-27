# This is how we rip our info from each password! With Regex!
#
# Note the `x` after, which is ignore whitespace, so we can comment this well.
# You'll also note `\s` which is a literal space to indicate yes, we want
# that one explicitly counted in our match.
PASSWORD_INFO = /
  # Beginning of line
  ^

  # Capture the entire thing as "input"
  (?<input>

    # Get the low count of the letter, capture it with the name low_count
    (?<low_count>\d+)

    # Ignore the dash
    -

    # and the high count
    (?<high_count>\d+)

    # literal space
    \s

    # Find our target letter
    (?<target_letter>[a-z]):

    \s

    # and the rest of the line is our password
    (?<password>[a-z]+)

  # End the input
  )

  # End of line
  $
/x

# One-line methods again. In this case we want to match against our Regex above,
# and if it found something we want the named captures:
#
# `(?<capture_name>capture_info)` for example
#
# Now we're doing something slightly confounded in transforming these to
# symbols, but it'll make sense in a moment to demo a fun new feature.
def extract_password(line) =
  line.match(PASSWORD_INFO)&.named_captures&.transform_keys(&:to_sym)

# Get the counts of each letter in a word. We _could_ potentially do
# this more efficiently but this works for demo purposes and the worst
# case input.
def letter_counts(word) =
  word.chars.each_with_object(Hash.new(0)) { |c, counts| counts[c] += 1 }

# Now we want to see which passwords are actually valid
def valid_passwords(input)
  # Filter map is fun. If the output is falsy it filters it out, otherwise it
  # keeps our shiny new transformed output. Think of it as combining `select`
  # and `map` into one function. I believe it was added in 2.7
  input.filter_map do
    # Yes yes, english operators are evil and I should quit stealing from Perl
    # early escapes. It's still useful as `next` returns `nil` if `extract_password`
    # happens to return `nil`, meaning no matches, or an invalid line of input.
    extracted_password = extract_password(_1) or next

    # Now this line is fun! This is why we transformed the input into symbol
    # keys. This is one-line right hand assignment, which means each of those
    # keys are now valid variables we can use in the rest of the function.
    #
    # I may well ask if MatchData can behave more like this naturally later,
    # could you imagine how useful that'd be?
    extracted_password => {
      input:, low_count:, high_count:, target_letter:, password:
    }

    # Now to make those counts into ints we can use.
    low_count  = low_count.to_i
    high_count = high_count.to_i

    # Then pull out the counts of each letter in the word, and get
    # only our target letter out of it. Again, not the most efficient, but
    # not the point of this exercise. Optimizing that is left as an
    # exercise to the reader.
    target_letter_count = letter_counts(password)[target_letter]

    # Now then, if that target letter count is between our high and low
    # bounds we return the input, otherwise we return `nil` meaning it's
    # invalid and it gets filtered out.
    (low_count..high_count).include?(target_letter_count) ? input : nil
  end
end

# Sometimes I mask reductions in signal, like all the valid passwords, so
# I can see what was actually valid. That, and I may well need that output
# elsewhere too.
def valid_password_count(...) = valid_passwords(...).size

# Hello `readlines` my old friend, I've come to call on you again because
# a problem softly ARGVing... ah, right. These lines won't change much
# on any of these problems.
File.readlines(ARGV[0]).then { puts valid_password_count(_1) }
