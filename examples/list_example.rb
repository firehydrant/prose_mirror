#!/usr/bin/env ruby
# Example with lists and code blocks

require_relative "../lib/prose_mirror"

# Document with lists and code blocks
json_document = <<~JSON
  {
    "type": "doc",
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 1 },
        "content": [
          { "type": "text", "text": "Lists and Code" }
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
                  { "type": "text", "text": "Second item" }
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

# Output the markdown
puts "Markdown Output:"
puts "----------------"
puts ProseMirror.to_markdown(document)
puts
puts "Raw document structure (for debugging):"
puts "--------------------------------------"

def print_node(node, indent = 0)
  prefix = "  " * indent
  if node.is_text
    puts "#{prefix}TEXT: '#{node.text}'"
  else
    puts "#{prefix}NODE: #{node.type.name} #{node.attrs unless node.attrs.empty?}"
    node.each_with_index do |child, i|
      print_node(child, indent + 1)
    end
  end
end

print_node(document)
