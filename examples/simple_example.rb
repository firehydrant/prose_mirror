#!/usr/bin/env ruby
# Simple example of using ProseMirror Ruby

require_relative "../lib/prose_mirror"

# A simple document with a heading and a paragraph
json_document = <<~JSON
  {
    "type": "doc",
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [
          { "type": "text", "text": "Hello ProseMirror" }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "This is a simple example of ProseMirror in Ruby." }
        ]
      }
    ]
  }
JSON

# Parse JSON into a Node object tree
document = ProseMirror.parse(json_document)

# Output the document structure
puts "Document Structure:"
puts "-------------------"
puts "Type: #{document.type.name}"

document.each_with_index do |node, i|
  puts "Child #{i}: #{node.type.name}"
  if node.type.name == "heading"
    puts "  Level: #{node.attrs[:level]}"
    puts "  Text: #{node.text_content}"
  else
    puts "  Text: #{node.text_content}"
  end
end

puts "\nMarkdown Output:"
puts "----------------"
puts ProseMirror.to_markdown(document)
