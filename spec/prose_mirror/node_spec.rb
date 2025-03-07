RSpec.describe ProseMirror::Node do
  let(:text_node) { ProseMirror::Node.new("text", {}, [], [], "Sample text") }
  let(:paragraph_node) { ProseMirror::Node.new("paragraph", {}, [text_node]) }

  describe "#is_text" do
    it "returns true for text nodes" do
      expect(text_node.is_text).to be true
    end

    it "returns false for non-text nodes" do
      expect(paragraph_node.is_text).to be false
    end
  end

  describe "#text_content" do
    it "returns the text directly for text nodes" do
      expect(text_node.text_content).to eq("Sample text")
    end

    it "returns the concatenated text of all child nodes for non-text nodes" do
      expect(paragraph_node.text_content).to eq("Sample text")
    end
  end

  describe "#child_count" do
    it "returns the number of child nodes" do
      expect(text_node.child_count).to eq(0)
      expect(paragraph_node.child_count).to eq(1)
    end
  end

  describe "#with_text" do
    it "creates a new text node with the given text" do
      new_node = text_node.with_text("New text")
      expect(new_node.text).to eq("New text")
      expect(new_node.marks).to eq(text_node.marks)
    end
  end
end
