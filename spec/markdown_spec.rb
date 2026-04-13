require "spec_helper"

RSpec.describe "Markdown Support" do
  it "renders markdown block inside BBCode" do
    input = <<~BBCODE
      [h1]标题[/h1]
      [markdown]
      # Subtitle [b]bold[/b]
      - ![xxx.img](xxx.img)
      - [yyy](yyy)
      ---
      <script>alert('xss')</script>
      [/markdown]
      [hr]
    BBCODE

    # Note: Our simple renderer doesn't support lists, so it should stay as text
    # But it should support headers, hr, links, images, and escape html.
    
    output = SoberBBCode.render(input)
    
    expect(output).to include("<h1>标题</h1>")
    expect(output).to include("<h1>Subtitle [b]bold[/b]</h1>")
    expect(output).to include("<hr>") # --- -> <hr>
    expect(output).to include("&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;") # Escaped
    expect(output).not_to include("<script>")
    expect(output).to include("<img src=\"xxx.img\" alt=\"xxx.img\">")
    expect(output).to include("<a href=\"yyy\">yyy</a>")
    expect(output).to include("<hr>") # [hr] -> <hr>
  end

  it "allows overriding the markdown renderer" do
    SoberBBCode.configure do |config|
      config.markdown_renderer = ->(text) { "CUSTOM: #{text.strip}" }
    end

    input = "[markdown]test[/markdown]"
    expect(SoberBBCode.render(input)).to eq("CUSTOM: test")

    # Reset configuration for other tests
    SoberBBCode.instance_variable_set(:@configuration, nil)
  end

  it "handles case-insensitive closing tags for raw content" do
    input = "[markdown]content[/MARKDOWN]"
    expect(SoberBBCode.render(input)).to include("content")
  end
end
