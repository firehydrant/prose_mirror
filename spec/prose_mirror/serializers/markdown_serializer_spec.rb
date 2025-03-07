RSpec.describe ProseMirror::Serializers::MarkdownSerializer do
  let(:json_document) do
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

  describe "#serialize" do
    let(:document) { ProseMirror::Converter.from_json(json_document) }
    let(:serializer) do
      ProseMirror::Serializers::MarkdownSerializer.new(
        ProseMirror::Serializers::MarkdownSerializer::DEFAULT_NODE_SERIALIZERS,
        ProseMirror::Serializers::MarkdownSerializer::DEFAULT_MARK_SERIALIZERS
      )
    end

    it "converts a document to markdown" do
      markdown = serializer.serialize(document)
      expected = "## Example Document\n\n**This is bold text** and *this is italic*."
      expect(markdown).to eq(expected)
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
