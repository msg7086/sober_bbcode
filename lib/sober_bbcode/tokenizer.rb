require "strscan"

module SoberBBCode
  class Tokenizer
    Token = Struct.new(:type, :content, :attributes, :position, keyword_init: true)

    def initialize(input)
      @scanner = StringScanner.new(input.to_s)
      @tokens = []
    end

    def tokenize
      until @scanner.eos?
        if @scanner.scan(/\[/)
          scan_tag_or_text
        else
          scan_text
        end
      end
      @tokens
    end

    private

    def scan_tag_or_text
      start_pos = @scanner.pos - 1 # Include the '['

      # Case 1: Closing tag [/tag]
      if @scanner.scan(/\//)
        scan_closing_tag(start_pos)
      # Case 2: Opening tag [tag] or [tag=value]
      elsif @scanner.check(/[a-zA-Z*]/)
        scan_opening_tag(start_pos)
      # Case 3: Not a tag, treat as text
      else
        add_text_token("[")
      end
    end

    def scan_closing_tag(start_pos)
      if @scanner.scan(/([a-zA-Z][a-zA-Z0-9]*|\*)\]/)
        tag_name = @scanner[1]
        @tokens << Token.new(
          type: :close_tag,
          content: tag_name.downcase,
          position: start_pos
        )
      else
        # Not a valid closing tag, treat as text
        add_text_token(@scanner.string[start_pos...@scanner.pos])
      end
    end

    def scan_opening_tag(start_pos)
      if @scanner.scan(/([a-zA-Z][a-zA-Z0-9]*|\*)(?:=(.*?))?\]/)
        tag_name = @scanner[1]
        attr_string = @scanner[2]
        
        @tokens << Token.new(
          type: :open_tag,
          content: tag_name.downcase,
          attributes: attr_string,
          position: start_pos
        )
      else
        # Not a valid opening tag, backtrack and treat '[' as text
        # But since we didn't consume anything extra yet (only checked),
        # we treat the initial '[' as text and let the loop continue.
        # Actually, if the regex fails but we are here, it means we saw `[` 
        # but didn't match the full tag syntax.
        # We need to be careful not to infinite loop.
        # Since we scanned `[` in the main loop, we just add it as text.
        add_text_token("[")
      end
    end

    def scan_text
      text = @scanner.scan(/[^\[]+/)
      add_text_token(text) if text
    end

    def add_text_token(text)
      if @tokens.last && @tokens.last.type == :text
        @tokens.last.content << text
      else
        @tokens << Token.new(type: :text, content: text, position: @scanner.pos - text.length)
      end
    end
  end
end
