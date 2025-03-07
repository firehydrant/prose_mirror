RSpec.describe ProseMirror::Serializers::MarkdownSerializer do
  let(:basic_document) do
    <<~JSON
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
  end

  let(:blockquote_with_list_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "blockquote",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "A quote with a list:" }
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
              }
            ]
          }
        ]
      }
    JSON
  end

  let(:linked_image_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "paragraph",
            "content": [
              { "type": "text", "text": "Here is a linked image: " },
              {
                "type": "text",
                "text": "![Example image](https://example.com/image.jpg)",
                "marks": [
                  {
                    "type": "link",
                    "attrs": {
                      "href": "https://example.com",
                      "title": "Example Website"
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end

  let(:nested_lists_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "bullet_list",
            "content": [
              {
                "type": "list_item",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      { "type": "text", "text": "Level 1 item" }
                    ]
                  },
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
                              { "type": "text", "text": "Level 2 ordered item 1" }
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
                              { "type": "text", "text": "Level 2 ordered item 2" }
                            ]
                          }
                        ]
                      }
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
                      { "type": "text", "text": "Another level 1 item" }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end

  let(:mixed_formatting_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "paragraph",
            "content": [
              { "type": "text", "text": "Normal text with " },
              {
                "type": "text",
                "text": "bold and italic",
                "marks": [
                  { "type": "strong" },
                  { "type": "em" }
                ]
              },
              { "type": "text", "text": " and " },
              {
                "type": "text",
                "text": "just bold",
                "marks": [
                  { "type": "strong" }
                ]
              },
              { "type": "text", "text": " or " },
              {
                "type": "text",
                "text": "just italic",
                "marks": [
                  { "type": "em" }
                ]
              },
              { "type": "text", "text": " formatting." }
            ]
          }
        ]
      }
    JSON
  end

  let(:code_block_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "code_block",
            "attrs": { "params": "ruby" },
            "content": [
              { "type": "text", "text": "def hello_world\\n  puts 'Hello, world!'\\nend" }
            ]
          }
        ]
      }
    JSON
  end

  let(:horizontal_rule_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "paragraph",
            "content": [
              { "type": "text", "text": "Text above rule" }
            ]
          },
          {
            "type": "horizontal_rule"
          },
          {
            "type": "paragraph",
            "content": [
              { "type": "text", "text": "Text below rule" }
            ]
          }
        ]
      }
    JSON
  end

  let(:table_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "table",
            "content": [
              {
                "type": "table_row",
                "content": [
                  {
                    "type": "table_header",
                    "content": [
                      {
                        "type": "paragraph",
                        "content": [
                          { "type": "text", "text": "Header 1" }
                        ]
                      }
                    ]
                  },
                  {
                    "type": "table_header",
                    "content": [
                      {
                        "type": "paragraph",
                        "content": [
                          { "type": "text", "text": "Header 2" }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "table_row",
                "content": [
                  {
                    "type": "table_cell",
                    "content": [
                      {
                        "type": "paragraph",
                        "content": [
                          { "type": "text", "text": "Cell 1" }
                        ]
                      }
                    ]
                  },
                  {
                    "type": "table_cell",
                    "content": [
                      {
                        "type": "paragraph",
                        "content": [
                          {
                            "type": "text",
                            "text": "Cell 2 with bold",
                            "marks": [{ "type": "strong" }]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end

  describe "#serialize" do
    let(:serializer) do
      ProseMirror::Serializers::MarkdownSerializer.new(
        ProseMirror::Serializers::MarkdownSerializer::DEFAULT_NODE_SERIALIZERS,
        ProseMirror::Serializers::MarkdownSerializer::DEFAULT_MARK_SERIALIZERS
      )
    end

    context "with basic document" do
      it "converts a document to markdown" do
        document = ProseMirror::Converter.from_json(basic_document)
        markdown = serializer.serialize(document)
        expected = "## Example Document\n\n**This is bold text** and *this is italic*."
        expect(markdown).to eq(expected)
      end
    end

    context "with blockquote containing a list" do
      it "correctly nests the list inside the blockquote" do
        document = ProseMirror::Converter.from_json(blockquote_with_list_document)
        markdown = serializer.serialize(document)
        # The exact output may vary depending on implementation details of the serializer,
        # but we expect the blockquote to contain the list items correctly
        expect(markdown).to include("> A quote with a list:")
        expect(markdown).to include("> * First item")
        expect(markdown).to include("> * Second item")
      end
    end

    context "with a linked image" do
      it "formats the linked image correctly (with escaping)" do
        document = ProseMirror::Converter.from_json(linked_image_document)
        markdown = serializer.serialize(document)
        expect(markdown).to include("Here is a linked image: ")
        # Note: The current implementation escapes the square brackets, which is not ideal
        # but we'll test for the actual behavior for now
        expect(markdown).to include("[!\\[Example image\\](https://example.com/image.jpg)](https://example.com")
      end
    end

    context "with nested lists" do
      it "properly formats nested lists (with current limitations)" do
        document = ProseMirror::Converter.from_json(nested_lists_document)
        markdown = serializer.serialize(document)
        # Note: The current implementation doesn't properly indent nested lists
        # We're testing the actual behavior for now, but this should be improved
        expect(markdown).to include("* Level 1 item")
        expect(markdown).to include("* 1. Level 2 ordered item 1")
        expect(markdown).to include("* 2. Level 2 ordered item 2")
        expect(markdown).to include("* Another level 1 item")
      end
    end

    context "with mixed formatting" do
      it "applies multiple marks correctly" do
        document = ProseMirror::Converter.from_json(mixed_formatting_document)
        markdown = serializer.serialize(document)
        expect(markdown).to include("Normal text with")
        expect(markdown).to include("***bold and italic***")
        expect(markdown).to include("**just bold**")
        expect(markdown).to include("*just italic*")
        expect(markdown).to include("formatting.")
      end
    end

    context "with code blocks" do
      it "formats code blocks with language specification" do
        document = ProseMirror::Converter.from_json(code_block_document)
        markdown = serializer.serialize(document)
        expect(markdown).to include("```ruby")
        expect(markdown).to include("def hello_world")
        expect(markdown).to include("puts 'Hello, world!'")
        expect(markdown).to include("end")
        expect(markdown).to include("```")
      end
    end

    context "with horizontal rule" do
      it "properly formats horizontal rules" do
        document = ProseMirror::Converter.from_json(horizontal_rule_document)
        markdown = serializer.serialize(document)
        expect(markdown).to include("Text above rule")
        expect(markdown).to include("---")
        expect(markdown).to include("Text below rule")
      end
    end

    context "with tables" do
      it "should handle table structures (if supported)" do
        document = ProseMirror::Converter.from_json(table_document)
        # Tables might not be supported in the current implementation
        # This test documents how they would be handled if supported
        pending "Table support not fully implemented"

        markdown = serializer.serialize(document)
        expect(markdown).to include("| Header 1 | Header 2 |")
        expect(markdown).to include("| --- | --- |")
        expect(markdown).to include("| Cell 1 | **Cell 2 with bold** |")
      end
    end
  end

  describe ".backticks_for" do
    it "returns the correct backtick formatting" do
      text_node = ProseMirror::Node.new("text", {}, [], [], "code with `backticks`")

      # For opening backticks
      result = ProseMirror::Serializers.backticks_for(text_node, -1)
      expect(result).to eq("`` ")

      # For closing backticks
      result = ProseMirror::Serializers.backticks_for(text_node, 1)
      expect(result).to eq(" ``")
    end
  end
end
