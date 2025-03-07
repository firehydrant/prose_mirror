RSpec.describe ProseMirror::Converter do
  let(:json_document) do
    <<~JSON
      {
        "type": "doc",
        "content": [
          {
            "type": "paragraph",
            "content": [
              {
                "type": "text",
                "text": "Hello World",
                "marks": [
                  {
                    "type": "strong"
                  }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end

  describe ".from_json" do
    let(:document) { ProseMirror::Converter.from_json(json_document) }

    it "parses the document type correctly" do
      expect(document.type.name).to eq("doc")
    end

    it "parses nested nodes correctly" do
      paragraph = document.child(0)
      expect(paragraph.type.name).to eq("paragraph")

      text = paragraph.child(0)
      expect(text.type.name).to eq("text")
      expect(text.text).to eq("Hello World")
    end

    it "parses marks correctly" do
      text = document.child(0).child(0)
      expect(text.marks.length).to eq(1)
      expect(text.marks[0].type.name).to eq("strong")
    end
  end
end
