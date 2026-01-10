require "spec_helper"

RSpec.describe "Custom Tags" do
  describe "align tag" do
    it "renders align=center" do
      input = "[align=center]centered text[/align]"
      expected = "<div style=\"text-align: center;\">centered text</div>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "renders align=left" do
      input = "[align=left]left-aligned text[/align]"
      expected = "<div style=\"text-align: left;\">left-aligned text</div>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "center tag" do
    it "renders center tag" do
      input = "[center]centered text[/center]"
      expected = "<div>centered text</div>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "table tags" do
    it "renders a simple table" do
      input = "[table][tr][td]cell 1[/td][td]cell 2[/td][/tr][/table]"
      expected = "<table><tbody><tr><td>cell 1</td><td>cell 2</td></tr></tbody></table>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "renders a table with multiple rows" do
      input = "[table][tr][td]r1c1[/td][td]r1c2[/td][/tr][tr][td]r2c1[/td][td]r2c2[/td][/tr][/table]"
      expected = "<table><tbody><tr><td>r1c1</td><td>r1c2</td></tr><tr><td>r2c1</td><td>r2c2</td></tr></tbody></table>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "handles newlines inside tables correctly" do
      input = "[table]\n[tr]\n[td]cell 1[/td]\n[td]cell 2[/td]\n[/tr]\n[/table]"
      expected = "<table><tbody><tr><td>cell 1</td><td>cell 2</td></tr></tbody></table>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end
end
