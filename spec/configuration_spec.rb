require "spec_helper"
require "sober_bbcode"

RSpec.describe SoberBBCode::Configuration do
  let(:config) { described_class.new }

  describe "default tags" do
    it "includes basic formatting tags" do
      expect(config.tags["b"]).to be_a(SoberBBCode::Configuration::TagDefinition)
      expect(config.tags["b"].html_tag).to eq("strong")

      expect(config.tags["i"]).to be_a(SoberBBCode::Configuration::TagDefinition)
      expect(config.tags["i"].html_tag).to eq("em")
    end

    it "includes block tags" do
      expect(config.tags["quote"]).to be_a(SoberBBCode::Configuration::TagDefinition)
      expect(config.tags["quote"].html_tag).to eq("blockquote")
      expect(config.tags["quote"].priority).to eq(1)
    end
  end

  describe "#add_tag" do
    it "allows adding a new tag" do
      config.add_tag(:custom, html_tag: "span", attributes: [:class])
      
      tag = config.tags["custom"]
      expect(tag).not_to be_nil
      expect(tag.name).to eq("custom")
      expect(tag.html_tag).to eq("span")
      expect(tag.attributes).to eq([:class])
    end

    it "normalizes tag names to downcase string" do
      config.add_tag(:UPPER, html_tag: "div")
      expect(config.tags["upper"]).to be_a(SoberBBCode::Configuration::TagDefinition)
    end
    
    it "overwrites existing tags" do
      config.add_tag(:b, html_tag: "b")
      expect(config.tags["b"].html_tag).to eq("b")
    end
  end
end
