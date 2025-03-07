# ProseMirror Ruby

A Ruby library for working with [ProseMirror](https://prosemirror.net/) documents, including conversion between ProseMirror JSON and other formats like Markdown.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prose_mirror_ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install prose_mirror_ruby
```

## Features

- Parse ProseMirror JSON documents into Ruby objects
- Convert ProseMirror documents to Markdown
- Traverse and manipulate document nodes
- Apply marks (like strong, em, code, etc.) to text nodes

## Usage

### Parsing ProseMirror JSON

```ruby
require 'prose_mirror'

# Example ProseMirror JSON document
json_document = <<~JSON
  {
    "type": "doc",
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [
          { "type": "text", "text": "Example Document" }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "This is bold text",
            "marks": [
              { "type": "strong" }
            ]
          },
          { "type": "text", "text": " and " },
          {
            "type": "text",
            "text": "this is italic",
            "marks": [
              { "type": "em" }
            ]
          },
          { "type": "text", "text": "." }
        ]
      }
    ]
  }
JSON

# Parse JSON into a Node object tree
document = ProseMirror.parse(json_document)
```

### Converting to Markdown

```ruby
# Convert a document to Markdown
markdown = ProseMirror.to_markdown(document)
puts markdown
```

### Working with Nodes

```ruby
# Traverse the document and print text nodes
def traverse_and_print(node, level = 0)
  indent = "  " * level

  if node.is_text
    puts "#{indent}Text: #{node.text}"
  else
    puts "#{indent}Node: #{node.type.name}"

    node.each_with_index do |child, i|
      traverse_and_print(child, level + 1)
    end
  end
end

traverse_and_print(document)
```

### Custom Markdown Serialization

You can customize the Markdown serialization by providing your own node and mark serializers:

```ruby
# Add a custom serializer for a new node type
custom_node_serializers = ProseMirror::Serializers::MarkdownSerializer::DEFAULT_NODE_SERIALIZERS.dup
custom_node_serializers[:custom_node] = ->(state, node, parent = nil, index = nil) {
  state.write("CUSTOM NODE: #{node.attrs[:custom_data]}")
  state.close_block(node)
}

# Create a serializer with custom node handlers
serializer = ProseMirror::Serializers::MarkdownSerializer.new(
  custom_node_serializers,
  ProseMirror::Serializers::MarkdownSerializer::DEFAULT_MARK_SERIALIZERS
)

# Use the custom serializer
markdown = serializer.serialize(document)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

For developers looking to contribute or extend this gem, the test suite includes examples of various complex ProseMirror document structures including:

- Blockquotes with embedded lists
- Linked images
- Nested lists (ordered and unordered)
- Mixed formatting (bold and italic combined)
- Code blocks with language specification
- Horizontal rules
- Tables (pending implementation)

These tests serve as documentation for how different structures are (or should be) handled.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/firehydrant/prose_mirror.

## Known Issues

- Markdown serialization for lists and code blocks may not produce perfect output in all cases. Contributions to improve this are welcome.
- Complex document structures like nested lists, linked images, and tables have varying levels of support:
  - Basic formatting (bold, italic, links) works well
  - Blockquotes with lists have limited formatting
  - Nested lists now have improved indentation but still add extra markers
  - Tables are not currently supported

## Recent Improvements

- **Better Nested List Handling**: The library now supports improved indentation for nested lists (e.g., ordered lists inside bullet lists or vice versa), making the generated Markdown more readable.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
