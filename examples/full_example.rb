#!/usr/bin/env ruby
# Comprehensive example of ProseMirror Ruby

require_relative "../lib/prose_mirror"

# A document with various elements
json_document = <<~JSON
  {
    "type": "doc",
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 1 },
        "content": [
          { "type": "text", "text": "ProseMirror Ruby" }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "This is a paragraph with " },
          {
            "type": "text",
            "text": "bold",
            "marks": [{ "type": "strong" }]
          },
          { "type": "text", "text": " and " },
          {
            "type": "text",
            "text": "italic",
            "marks": [{ "type": "em" }]
          },
          { "type": "text", "text": " text." }
        ]
      },
      {
        "type": "bullet_list",
        "attrs": { "tight": true },
        "content": [
          {
            "type": "list_item",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "Bulleted item 1" }
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
                  { "type": "text", "text": "Bulleted item 2" }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "ordered_list",
        "attrs": { "tight": true, "order": 1 },
        "content": [
          {
            "type": "list_item",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "Ordered item 1" }
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
                  { "type": "text", "text": "Ordered item 2" }
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
          { "type": "text", "text": "# Ruby code example\\ndef hello\\n  puts 'Hello, world!'\\nend" }
        ]
      },
      {
        "type": "blockquote",
        "content": [
          {
            "type": "paragraph",
            "content": [
              { "type": "text", "text": "This is a blockquote" }
            ]
          }
        ]
      },
      {
        "type": "paragraph",
        "content": [
          { "type": "text", "text": "A link to " },
          {
            "type": "text",
            "text": "Ruby",
            "marks": [
              {
                "type": "link",
                "attrs": {
                  "href": "https://www.ruby-lang.org",
                  "title": "Ruby Programming Language"
                }
              }
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

# Convert to markdown and display
markdown = ProseMirror.to_markdown(document)

puts "ProseMirror Ruby - Full Example"
puts "==============================="
puts
puts "Markdown Output:"
puts "----------------"
puts markdown
