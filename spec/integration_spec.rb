require "spec_helper"

RSpec.describe SoberBBCode do
  describe ".parse" do
    it "parses a string into an AST" do
      root = SoberBBCode.parse("[b]Bold[/b]")
      expect(root).to be_a(SoberBBCode::Nodes::Root)
      expect(root.children.first).to be_a(SoberBBCode::Nodes::Tag)
      expect(root.children.first.name).to eq("b")
    end
  end

  describe "Complex Article Rendering" do
    it "renders a full article with mixed tags" do
      input = <<~BBCODE
        [h1]My Article[/h1]
        [b]Introduction[/b]
        This is a paragraph with [i]italic[/i] and [u]underline[/u].
        [hr]
        [h2]Features[/h2]
        [ul]
          [li]Feature 1[/li]
          [li]Feature 2: [code]code block[/code][/li]
        [/ul]
        [ol]
          [li]Step 1[/li]
          [li]Step 2[/li]
        [/ol]
        [quote]This is a quote.[/quote]
        [center]Centered Text[/center]
      BBCODE

      expected = "<h1>My Article</h1><br><strong>Introduction</strong><br>This is a paragraph with <em>italic</em> and <u>underline</u>.<br><hr><br><h2>Features</h2><br><ul><li>Feature 1</li><li>Feature 2: <pre>code block</pre></li></ul><br><ol><li>Step 1</li><li>Step 2</li></ol><br><blockquote>This is a quote.</blockquote><br><div>Centered Text</div><br>"

      # Remove newlines from input and expected to simplify matching
      # since the compiler might not preserve whitespace exactly as we typed in heredoc
      # But based on current implementation, it joins children directly.
      # So newlines in input text nodes are preserved.

      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "strips orphan list items (li without parent)" do
      input = "start [li]Orphan Item[/li] end"
      # Expecting the orphan li to be ignored/stripped or rendered as text?
      # The requirement is to "fix this scenario".
      # Usually orphan li should be either treated as text or stripped.
      # Let's say we want to treat it as plain text or ignore it to produce valid HTML.
      # If we treat it as plain text, it would be "start Orphan Item end" (if tags stripped) or raw.

      # However, the user said "repair this scenario" (repair/fix).
      # A common fix is to auto-wrap them in <ul> or just render content without <li> tag?
      # Or maybe just don't render <li> tags if not inside <ul>/<ol>.

      # Let's check current behavior first.
      # Currently, it will render <li>Orphan Item</li> which is invalid HTML without ul/ol.
      # "Fixing" it implies making it valid or harmless.
      # Let's decide to render the content without the <li> tag if parent is not a list.
      # But checking parent in Compiler might be tricky if AST doesn't have parent links.

      # Wait, the compiler visits recursively.
      # We can pass context down.

      # BUT, "repair" might also mean effectively treating it as text or auto-wrapping.
      # Let's assume the safest "fix" is to NOT render <li> tags if not inside a list container.
      # So it renders just the content.

      expected = "start Orphan Item end"
      expect(SoberBBCode.render(input)).to eq(expected)
    end

    it "renders real-world user data with whitespace and mixed tags" do
      input = <<~BBCODE
        [img]https://i0.wp.com/pic.bstarstatic.com/ogv/426d0ef6bc29837cebbbba802b480519b5f9e453.png@1280w_720h_100Q_1c.jpg[/img]

        [h3][b][i][i]A Record Of Mortal's Journey To Immortality[/i][/i][/b] - EP 175[/h3]
        [b][url=https://anilist.co/anime/159599]AniList[/url] | [url=https://bgm.tv/subject/348240]bangumi.tv[/url] | [url=https://myanimelist.net/anime/41219]MAL[/url] | [url=https://www.themoviedb.org/tv/106449]TMDB[/url][/b]

        [b]Information:[/b]
        [ul][li][b]Overall Bit Rate:[/b] 4 606 kb/s[/li]
        [li][b]Subtitle:[/b] English, ภาษาไทย, Tiếng Việt, Bahasa Indonesia, Bahasa Melayu[/li]
        [li][b]Duration:[/b] 00:18:11.818[/li]
        [li][b]CRC32:[/b] 0C8A6A70[/li]
        [li][b][url=https://rr1---nfo.ouo.si/%5BDynamis%20One%5D%20A%20Record%20Of%20Mortal%27s%20Journey%20To%20Immortality%20-%20175%20%28B-Global%20Donghua%201920x1080%20HEVC%20AAC%20MKV%29%20%5B0C8A6A70%5D.mkv.nfo]MediaInfo[/url][/b][/li]
        [/ul]
        In case of any issues with the file, please let us know via the contact details below.
        [b]Xunlei has been banned by default.[/b]
        [b]Seeding after downloading is appreciated.[/b]

        [b]Contact:[/b] [ul]
        [li][b]Rel: [url=https://ouo.si/user/BraveSail]ouo.si[/url] | [url=https://mikanani.me/Home/PublishGroup/392]Mikan Project[/url] | [url=https://bangumi.moe/search/63e4b7585fa12c0007949b88]bangumi.moe[/url] | [url=https://acg.rip/user/5570]acg.rip[/url] | [url=https://share.acgnx.se/user-529-1.html]acgnx.se[/url][/b][/li]
        [li]Join us on [url=https://kirara-fantasia.moe/telegram]Telegram[/url] | [url=https://kirara-fantasia.moe/discord]Discord[/url][/li]
        [/ul]
      BBCODE

      expected = <<~HTML.gsub("\n", "").gsub("TEMP_BR", "<br>")
        <img src="https://i0.wp.com/pic.bstarstatic.com/ogv/426d0ef6bc29837cebbbba802b480519b5f9e453.png@1280w_720h_100Q_1c.jpg">TEMP_BR
        TEMP_BR
        <h3><strong><em><em>A Record Of Mortal&#39;s Journey To Immortality</em></em></strong> - EP 175</h3>TEMP_BR
        <strong><a href="https://anilist.co/anime/159599">AniList</a> | <a href="https://bgm.tv/subject/348240">bangumi.tv</a> | <a href="https://myanimelist.net/anime/41219">MAL</a> | <a href="https://www.themoviedb.org/tv/106449">TMDB</a></strong>TEMP_BR
        TEMP_BR
        <strong>Information:</strong>TEMP_BR
        <ul><li><strong>Overall Bit Rate:</strong> 4 606 kb/s</li><li><strong>Subtitle:</strong> English, ภาษาไทย, Tiếng Việt, Bahasa Indonesia, Bahasa Melayu</li><li><strong>Duration:</strong> 00:18:11.818</li><li><strong>CRC32:</strong> 0C8A6A70</li><li><strong><a href="https://rr1---nfo.ouo.si/%5BDynamis%20One%5D%20A%20Record%20Of%20Mortal%27s%20Journey%20To%20Immortality%20-%20175%20%28B-Global%20Donghua%201920x1080%20HEVC%20AAC%20MKV%29%20%5B0C8A6A70%5D.mkv.nfo">MediaInfo</a></strong></li></ul>TEMP_BR
        In case of any issues with the file, please let us know via the contact details below.TEMP_BR
        <strong>Xunlei has been banned by default.</strong>TEMP_BR
        <strong>Seeding after downloading is appreciated.</strong>TEMP_BR
        TEMP_BR
        <strong>Contact:</strong> <ul><li><strong>Rel: <a href="https://ouo.si/user/BraveSail">ouo.si</a> | <a href="https://mikanani.me/Home/PublishGroup/392">Mikan Project</a> | <a href="https://bangumi.moe/search/63e4b7585fa12c0007949b88">bangumi.moe</a> | <a href="https://acg.rip/user/5570">acg.rip</a> | <a href="https://share.acgnx.se/user-529-1.html">acgnx.se</a></strong></li><li>Join us on <a href="https://kirara-fantasia.moe/telegram">Telegram</a> | <a href="https://kirara-fantasia.moe/discord">Discord</a></li></ul>TEMP_BR
      HTML

      expect(SoberBBCode.render(input)).to eq(expected)
    end
  end
end
