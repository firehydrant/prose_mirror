RSpec.describe ProseMirror::Mark do
  let(:strong_mark) { ProseMirror::Mark.new("strong") }
  let(:link_mark) { ProseMirror::Mark.new("link", {href: "https://example.com"}) }
  let(:another_strong_mark) { ProseMirror::Mark.new("strong", {weight: "bold"}) }

  describe "#eq" do
    it "returns true for marks with the same type" do
      expect(strong_mark.eq(another_strong_mark)).to be true
    end

    it "returns false for marks with different types" do
      expect(strong_mark.eq(link_mark)).to be false
    end
  end

  describe "#is_in_set" do
    it "returns true when the mark is in the set" do
      mark_set = [link_mark, another_strong_mark]
      expect(strong_mark.is_in_set(mark_set)).to be true
    end

    it "returns false when the mark is not in the set" do
      mark_set = [link_mark]
      expect(strong_mark.is_in_set(mark_set)).to be false
    end
  end

  describe "attributes" do
    it "stores attributes properly" do
      expect(link_mark.attrs[:href]).to eq("https://example.com")
    end
  end
end
