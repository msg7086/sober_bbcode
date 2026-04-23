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

    it "renders align=right" do
      input = "[align=right]right-aligned text[/align]"
      expected = "<div style=\"text-align: right;\">right-aligned text</div>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "left tag" do
    it "renders left tag with left alignment" do
      input = "[left]left text[/left]"
      expected = "<div style=\"text-align: left;\">left text</div>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "center tag" do
    it "renders center tag" do
      input = "[center]centered text[/center]"
      expected = "<div style=\"text-align: center;\">centered text</div>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "right tag" do
    it "renders right tag with right alignment" do
      input = "[right]right text[/right]"
      expected = "<div style=\"text-align: right;\">right text</div>"
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

  describe "size tag" do
    it "renders em units" do
      input = "[size=2.5]em text[/size]"
      expected = "<span style=\"font-size: 2.5em;\">em text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "renders pt units" do
      input = "[size=20]pt text[/size]"
      expected = "<span style=\"font-size: 20pt;\">pt text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "renders percentage units" do
      input = "[size=150]percentage text[/size]"
      expected = "<span style=\"font-size: 150%;\">percentage text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "defaults to 2em for out-of-range positive values" do
      input = "[size=4]default text[/size]"
      expected = "<span style=\"font-size: 2em;\">default text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "is invalid for zero" do
      input = "[size=0]invalid text[/size]"
      expected = "<span>invalid text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "is invalid for negative values" do
      input = "[size=-1]invalid text[/size]"
      expected = "<span>invalid text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "color tag" do
    it "renders color style" do
      input = "[color=red]colored text[/color]"
      expected = "<span style=\"color: red;\">colored text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "escapes color attribute value" do
      input = "[color=<red>]safe[/color]"
      expected = "<span style=\"color: &lt;red&gt;;\">safe</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end

  describe "font tag" do
    it "renders font-family style" do
      input = "[font=Times New Roman]font text[/font]"
      expected = "<span style=\"font-family: Times New Roman;\">font text</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "escapes font attribute value" do
      input = "[font=\"Open Sans\"]safe[/font]"
      expected = "<span style=\"font-family: &quot;Open Sans&quot;;\">safe</span>"
      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end
end
