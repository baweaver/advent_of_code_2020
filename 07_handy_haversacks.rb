NO_BAGS = 'no other bags'
BAG_REGEX = /(?<color>.*) bags contain (?<children>.*)./
CHILD_BAG_REGEX = /(?<count>\d+) (?<color>\w+ \w+) bag/

TARGET_BAG = 'shiny gold'.freeze

# Oh yes, this is one of _those_ types of problems. We're going into the tree
# algorithms!
Node = Struct.new(:color, :children) do
  # First we want a way to display these nodes in case we need to
  # do any debugging. The indent is to make it look nicer. Even
  # if it's not a part of the solution it's real danged handy for
  # figuring out what went wrong.
  def to_s(indent: 0)
    # The indent is 100% to make the output look nicer for deep nesting
    children_strings = children
      .map { _1.to_s(indent: indent + 2).chomp }
      .join(", ")

    indent_space = ' ' * indent

    # We don't want to indent the first `{` as it's up against an
    # array bracket (`[`) and that'd look odd.
    #
    # Anyways, squiggly HEREDOCs (`<<~NAME`) trim whitespace to the left
    # automatically, hence using it here.
    <<~NODE
    {
    #{indent_space}  color:    #{color},
    #{indent_space}  children: [#{children_strings}]
    #{indent_space}}
    NODE
  end

  # Remember this is "contains", not "is". We want to know if any of
  # the bags inside our bag are a color we want
  def contains_color?(color)
    # So check each child's color, then their children's color
    children.any? { _1.color == color || _1.contains_color?(color) }
  end

  # Same idea as `contains_color?` above, except that we want the size
  # of this bags children as well as the sum of all the bags inside of
  # those bags. Bagception!
  def total_bags_inside
    children.size + children.map(&:total_bags_inside).sum
  end
end

# Parse out data from a child node, bags in bags
def parse_child_rule(children)
  # If this is a "no other bags" node, don't keep parsing
  return {} if children.include?(NO_BAGS)

  # Use scan to get all occurrences of child nodes
  children
    .scan(CHILD_BAG_REGEX)
    .map { |count, color| { count: count.to_i, color: color } }
end

# Parse an individual rule
def parse_rule(rule)
  # Same tricks as before
  rule = BAG_REGEX
    .match(rule)
    .named_captures
    .transform_keys(&:to_sym)
    # Except we transform the children into children nodes
    .tap { |cs| cs[:children] = parse_child_rule(cs[:children]) }

  { rule[:color] => rule[:children] }
end

# Create a tree of nodes. I have a real good reason to think we're
def create_tree(rules)
  # Combine all of our rules into one hash
  parsed_rules = rules.reduce({}) { |h, r| h.merge!(parse_rule(r)) }

  # Inner-function recursion which is useful because we want to use
  # closures to get at `parsed_rules` to grab rules for bag colors
  # since this thing nests deep.
  recurse = -> current_node do
    # One-line pattern match the color and count out
    current_node => { color:, count: }

    # Each color may well have more children below it, so we grab the
    # rule for that color and keep recursing down until we find an
    # instance of "no other bags".
    children = parsed_rules[color].flat_map(&recurse)

    # Now we have a count, so we need `count` instances of the node.
    [Node[color, children]] * count
  end

  # This drops us into the recursion. I could probably eliminate part
  # of this but don't quite want to at the moment.
  parsed_rules.map { |color, children| Node[color, children.flat_map(&recurse)] }
end

# Creates our tree, finds the target color, and gets total bags inside
def bags_inside_target(rules, target: TARGET_BAG)
  tree = create_tree(rules)
  tree.find { _1.color == target }.total_bags_inside
end

# Finds all bags containing the bag we're looking for
def bags_containing_target(rules, target: TARGET_BAG)
  tree = create_tree(rules)
  tree.select { |node| node.color != target && node.contains_color?(target) }
end

# Will separate out these two some time tomorrow
#
# Part One
# File.readlines(ARGV[0]).then { puts bags_containing_target(_1).size }

# Part Two
File.readlines(ARGV[0]).then { puts bags_inside_target(_1) }
