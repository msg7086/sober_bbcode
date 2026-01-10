require "spec_helper"
require "sober_bbcode/tokenizer"

RSpec.describe SoberBBCode::Tokenizer do
  subject { described_class.new(input).tokenize }

  context "with plain text" do
    let(:input) { "Hello World" }

    it "returns a single text token" do
      expect(subject.length).to eq(1)
      expect(subject.first.type).to eq(:text)
      expect(subject.first.content).to eq("Hello World")
    end
  end

  context "with simple tags" do
    let(:input) { "[b]Bold[/b]" }

    it "tokenizes correctly" do
      expect(subject.length).to eq(3)
      
      expect(subject[0].type).to eq(:open_tag)
      expect(subject[0].content).to eq("b")

      expect(subject[1].type).to eq(:text)
      expect(subject[1].content).to eq("Bold")

      expect(subject[2].type).to eq(:close_tag)
      expect(subject[2].content).to eq("b")
    end
  end

  context "with tags containing attributes" do
    let(:input) { "[url=https://example.com]Link[/url]" }

    it "captures attributes" do
      expect(subject[0].type).to eq(:open_tag)
      expect(subject[0].content).to eq("url")
      expect(subject[0].attributes).to eq("https://example.com")
    end
  end

  context "with mixed content" do
    let(:input) { "Start [b]Middle[/b] End" }

    it "tokenizes interspersed text and tags" do
      expect(subject.map(&:type)).to eq([:text, :open_tag, :text, :close_tag, :text])
      expect(subject.map(&:content)).to eq(["Start ", "b", "Middle", "b", " End"])
    end
  end

  context "with incomplete tags" do
    let(:input) { "This is [b not a tag" }

    it "treats incomplete tags as text" do
      expect(subject.length).to eq(1)
      expect(subject.first.type).to eq(:text)
      expect(subject.first.content).to eq("This is [b not a tag")
    end
  end
  
  context "with multiple brackets" do
    let(:input) { "[[b]Bold[/b]]" }

    it "handles nested brackets correctly" do
       # The tokenizer logic might need adjustment if it doesn't handle this exact case perfectly initially,
       # but let's see what the current implementation does.
       # Current implementation:
       # [ -> text (incomplete tag)
       # [b] -> open tag
       # Bold -> text
       # [/b] -> close tag
       # ] -> text
       
       # Actually, `[[b]` might be parsed as `[` (text) then `[b]` (tag)
       
       expect(subject.map(&:type)).to eq([:text, :open_tag, :text, :close_tag, :text])
       expect(subject[0].content).to eq("[")
       expect(subject[1].content).to eq("b")
       expect(subject[4].content).to eq("]")
    end
  end
end
