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

    # Get the first position
    (?<position_one>\d+)

    # Ignore the dash
    -

    # and the second position
    (?<position_two>\d+)

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
      input:, position_one:, position_two:, target_letter:, password:
    }

    # This is where things get different. Also pay attention to that
    # zero index note. Methinks the shopkeeper uses Lua.
    position_one = position_one.to_i - 1
    position_two = position_two.to_i - 1

    # Eh, slightly lazy one-line assignment. Grab those characters from the
    # password
    char_one, char_two = password[position_one], password[position_two]

    # Now we just check those two positions to see if the target letter is
    # there. Do note that `^` does _not_ have the same precedence as `||` or
    # `&&`, meaning it'll syntax error if you use equality checks there.
    #
    # What is it? XOR: exclusive OR, one or the other, but not both and not none
    input if (char_one == target_letter) ^ (char_two == target_letter)
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
