puts File
  .read(ARGV[0])
  # More blank-line for record separation
  .split(/\n\n/)
  # Delete all the whitespace, and find how many unique characters
  # there are in the new string
  .map { _1.gsub(/\W/, '').chars.uniq.size }
  # and get the total of that
  .sum
