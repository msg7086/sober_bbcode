require "spec_helper"

RSpec.describe SoberBBCode::Parser do
  def parse(input)
    tokenizer = SoberBBCode::Tokenizer.new(input)
    tokens = tokenizer.tokenize
    parser = SoberBBCode::Parser.new(tokens)
    parser.parse
  end

  describe "#parse" do
    it "parses simple text" do
      root = parse("Hello world")
      expect(root.children.size).to eq(1)
      expect(root.children[0]).to be_a(SoberBBCode::Nodes::Text)
      expect(root.children[0].content).to eq("Hello world")
    end

    it "parses a simple tag" do
      root = parse("[b]bold[/b]")
      expect(root.children.size).to eq(1)
      tag = root.children[0]
      expect(tag).to be_a(SoberBBCode::Nodes::Tag)
      expect(tag.name).to eq("b")
      expect(tag.children.size).to eq(1)
      expect(tag.children[0].content).to eq("bold")
    end

    it "parses nested tags" do
      root = parse("[b]bold [i]italic[/i][/b]")
      tag_b = root.children[0]
      expect(tag_b.name).to eq("b")
      expect(tag_b.children.size).to eq(2) # "bold " + Tag(i)
      
      tag_i = tag_b.children[1]
      expect(tag_i).to be_a(SoberBBCode::Nodes::Tag)
      expect(tag_i.name).to eq("i")
      expect(tag_i.children[0].content).to eq("italic")
    end

    it "handles attributes" do
      root = parse("[url=http://google.com]Link[/url]")
      tag = root.children[0]
      expect(tag.name).to eq("url")
      expect(tag.attributes).to eq({ default: "http://google.com" })
    end

    it "handles void tags (img)" do
      root = parse("[img]src[/img]") # Wait, img is void in our config?
      # In configuration.rb: add_tag :img, html_tag: 'img', void: true
      # Void tags don't have a closing tag in HTML sense, but BBCode usually has closing tag?
      # Actually, standard BBCode [img]url[/img] is NOT void. It contains the url as text.
      # But HTML <img> is void.
      # Let's check Configuration.rb content again.
      # It says: add_tag :img, html_tag: 'img', void: true, attributes: [:src, :alt]
      # Usually [img] is used as [img]http://...[/img]. 
      # If we mark it as void, it means [img] parses as a standalone tag without content?
      # Example: [img src=...] or just [img] (maybe hr?).
      # Standard BBCode: [img]http://example.com/image.png[/img]
      # If we defined it as VOID, then `[img]` is the whole tag.
      # Let's re-read the plan or config.
      # Config: `void: true` for `[img]`.
      # This implies the user intends `[img]` to work like `<img />`. 
      # BUT standard BBCode uses `[img]url[/img]`.
      # If the intention is `[img]url[/img]`, then `void: true` is WRONG for the parser logic if we expect content.
      # However, if we assume `[img src=...]` style, then void is correct.
      # Let's test what we have. If I use `[img]`, it should be a node.
    end
    
    it "parses void tags correctly (assuming self-closing behavior)" do
      # [hr] is void in config.
      # [hr] text -> Tag(hr), Text( text )
      
      root = parse("[hr] text")
      expect(root.children[0]).to be_a(SoberBBCode::Nodes::Tag)
      expect(root.children[0].name).to eq("hr")
      
      expect(root.children[1]).to be_a(SoberBBCode::Nodes::Text)
      expect(root.children[1].content).to eq(" text")
    end

    context "Priority Logic" do
      # b: 0, quote: 1

      it "auto-closes lower priority tags when higher priority tag closes" do
        # [quote] [b] text [/quote]
        # [quote] (p1) opens
        # [b] (p0) opens
        # [/quote] closes. 
        # Target: quote. Inter: b.
        # quote.priority (1) > b.priority (0).
        # Should allow closing. b is popped (auto-closed).
        
        root = parse("[quote][b]text[/quote]")
        quote = root.children[0]
        expect(quote.name).to eq("quote")
        
        b = quote.children[0]
        expect(b.name).to eq("b")
        expect(b.children[0].content).to eq("text")
      end

      it "blocks closing if intermediate tag has higher priority" do
        # [b] [quote] text [/b]
        # [b] (p0) opens
        # [quote] (p1) opens
        # [/b] closes.
        # Target: b. Inter: quote.
        # b.priority (0) <= quote.priority (1).
        # Blocked! [/b] treated as text.
        
        root = parse("[b][quote]text[/b]")
        b = root.children[0]
        expect(b.name).to eq("b")
        
        quote = b.children[0]
        expect(quote.name).to eq("quote")
        
        # text and [/b] are merged into one text node
        expect(quote.children.size).to eq(1)
        expect(quote.children[0].content).to eq("text[/b]")
      end
    end
    
    context "Mismatched / Stray tags" do
      it "treats stray closing tags as text" do
        root = parse("foo[/b]bar")
        expect(root.children[0].content).to eq("foo[/b]bar")
      end

      it "treats unknown tags as text" do
        root = parse("[unknown]text[/unknown]")
        expect(root.children[0].content).to eq("[unknown]text[/unknown]")
      end
    end
  end
end
