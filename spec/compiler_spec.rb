require "spec_helper"

RSpec.describe SoberBBCode::Compiler do
  def render(input)
    SoberBBCode.render(input)
  end

  describe "#to_html" do
    it "renders simple text with escaping" do
      expect(render("Hello <script>")).to eq("Hello &lt;script&gt;")
    end

    it "renders simple tags" do
      expect(render("[b]bold[/b]")).to eq("<strong>bold</strong>")
    end

    it "renders nested tags" do
      expect(render("[b]bold [i]italic[/i][/b]")).to eq("<strong>bold <em>italic</em></strong>")
    end

    it "renders attributes correctly" do
      expect(render("[url=http://google.com]Link[/url]")).to eq('<a href="http://google.com">Link</a>')
    end

    it "strips unsafe javascript: URLs" do
      expect(render("[url=javascript:alert('xss')]Link[/url]")).to eq('<a>Link</a>') # Attribute stripped
    end

    it "renders void tags" do
      # Assuming [img=src] usage per implementation decision
      expect(render("[img=http://image.com]")).to eq('<img src="http://image.com">')
    end

    describe "New Tags" do
      it "renders headings h1-h4" do
        expect(render("[h1]Title[/h1]")).to eq("<h1>Title</h1>")
        expect(render("[h2]Subtitle[/h2]")).to eq("<h2>Subtitle</h2>")
        expect(render("[h3]Section[/h3]")).to eq("<h3>Section</h3>")
        expect(render("[h4]Subsection[/h4]")).to eq("<h4>Subsection</h4>")
      end

      it "renders unordered lists" do
        input = "[ul][li]Item 1[/li][li]Item 2[/li][/ul]"
        expect(render(input)).to eq("<ul><li>Item 1</li><li>Item 2</li></ul>")
      end

      it "renders unordered lists 2" do
        input = "[list][li]Item 1[/li][li]Item 2[/li][/list]"
        expect(render(input)).to eq("<ul><li>Item 1</li><li>Item 2</li></ul>")
      end

      it "renders unordered lists 3" do
        input = "[list][*]Item 1\n[*]Item 2\n[/list]"
        expect(render(input)).to eq("<ul><li>Item 1</li><li>Item 2</li></ul>")
      end

      it "renders ordered lists" do
        input = "[ol][li]Item 1[/li][li]Item 2[/li][/ol]"
        expect(render(input)).to eq("<ol><li>Item 1</li><li>Item 2</li></ol>")
      end

      it "renders horizontal rule" do
        expect(render("Line 1[hr]Line 2")).to eq("Line 1<hr>Line 2")
      end
    end

    context "Complex Scenarios" do
      before do
        SoberBBCode.configure do |c|
          c.add_tag :table, html_tag: 'table', priority: 1
          c.add_tag :tr, html_tag: 'tr', priority: 0
          c.add_tag :td, html_tag: 'td', priority: 0
        end
      end

      it "renders quote containing table" do
        input = "[quote][table][tr][td]Cell[/td][/tr][/table][/quote]"
        expected = "<blockquote><table><tr><td>Cell</td></tr></table></blockquote>"
        expect(render(input)).to eq(expected)
      end

      it "handles broken nesting with priority" do
        # [quote] has p=1, [b] has p=0.
        # [quote][b]text[/quote] -> [b] should be auto-closed.
        input = "[quote][b]text[/quote]"
        expected = "<blockquote><strong>text</strong></blockquote>"
        expect(render(input)).to eq(expected)
      end
    end
  end
end
