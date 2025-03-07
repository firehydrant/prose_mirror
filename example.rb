#!/usr/bin/env ruby
# Example usage of the ProseMirror Ruby library

require_relative "lib/prose_mirror"

puts "ProseMirror Ruby Example"
puts "======================="
puts

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
      },
      {
        "type": "bullet_list",
        "content": [
          {
            "type": "list_item",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "First item" }
                ]
              }
            ]
          },
          {
            "type": "list_item",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "Second item with " },
                  {
                    "type": "text",
                    "text": "code",
                    "marks": [
                      { "type": "code" }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "code_block",
        "attrs": { "params": "ruby" },
        "content": [
          { "type": "text", "text": "puts 'Hello, world!'" }
        ]
      }
    ]
  }
JSON

# Parse JSON into a Node object tree
document = ProseMirror.parse(json_document)

# Display document structure
def traverse_and_print(node, level = 0)
  indent = "  " * level

  if node.is_text
    marks_text = node.marks.empty? ? "" : " [#{node.marks.map { |m| m.type.name }.join(", ")}]"
    puts "#{indent}Text: \"#{node.text}\"#{marks_text}"
  else
    attrs_text = node.attrs.empty? ? "" : " #{node.attrs.inspect}"
    puts "#{indent}Node: #{node.type.name}#{attrs_text}"

    node.each_with_index do |child, i|
      traverse_and_print(child, level + 1)
    end
  end
end

puts "Document structure:"
traverse_and_print(document)
puts

# Convert document to Markdown
markdown = ProseMirror.to_markdown(document)

puts "Markdown output:"
puts "================"
# Create a multiline string with the raw content
puts
puts "```markdown"
puts markdown
puts "```"
