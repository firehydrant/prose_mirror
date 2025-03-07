#!/usr/bin/env ruby
# Example with just an ordered list

require_relative "../lib/prose_mirror"

# Document with only an ordered list
json_document = <<~JSON
  {
    "type": "doc",
    "content": [
      {
        "type": "ordered_list",
        "attrs": { "order": 1 },
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
      }
    ]
  }
JSON

# Parse JSON into a Node object tree
document = ProseMirror.parse(json_document)

puts "Document Structure for Debugging:"
puts "--------------------------------"

def traverse_node(node, level = 0)
  indent = "  " * level
  if node.is_text
    puts "#{indent}Text: '#{node.text}'"
  else
    puts "#{indent}Node: #{node.type.name} #{node.attrs.inspect unless node.attrs.empty?}"
    node.each_with_index do |child, i|
      traverse_node(child, level + 1)
    end
  end
end

traverse_node(document)

puts "\nMarkdown Output:"
puts "----------------"
puts ProseMirror.to_markdown(document)
