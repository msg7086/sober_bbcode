require "spec_helper"

RSpec.describe "List and Asterisk Support" do
  it "renders a simple unordered list" do
    input = "[list][*]Item 1[*]Item 2[/list]"
    expected = "<ul><li>Item 1</li><li>Item 2</li></ul>"
    expect(SoberBBCode.render(input)).to eq(expected)
  end

  it "renders an ordered list with numeric type" do
    input = "[list=1][*]Item 1[*]Item 2[/list]"
    expected = '<ol type="1"><li>Item 1</li><li>Item 2</li></ol>'
    expect(SoberBBCode.render(input)).to eq(expected)
  end

  it "renders an ordered list with alphabetic type" do
    input = "[list=a][*]Item 1[*]Item 2[/list]"
    expected = '<ol type="a"><li>Item 1</li><li>Item 2</li></ol>'
    expect(SoberBBCode.render(input)).to eq(expected)
  end

  it "handles spaces and newlines around list items" do
    input = <<~BBCODE.strip
      [list]
      [*] Item 1
      [*] Item 2
      [/list]
    BBCODE
    expected = "<ul><li> Item 1</li><li> Item 2</li></ul>"
    expect(SoberBBCode.render(input)).to eq(expected)
  end
end
