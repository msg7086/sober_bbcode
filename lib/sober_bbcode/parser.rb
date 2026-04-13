module SoberBBCode
  class Parser
    def initialize(tokens)
      @tokens = tokens
      @root = Nodes::Root.new
      @stack = [@root]
      @config = SoberBBCode.configuration
    end

    def parse
      @tokens.each do |token|
        case token.type
        when :open_tag
          handle_open_tag(token)
        when :close_tag
          handle_close_tag(token)
        when :text
          add_text_node(token.content)
        end
      end

      # Close any remaining open tags at the end of the document
      while @stack.size > 1
        pop_stack
      end

      @root
    end

    private

    def current_node
      @stack.last
    end

    def handle_open_tag(token)
      tag_def = @config.tags[token.content]

      # If tag is not defined, treat as text
      unless tag_def
        add_text_node(token_to_text(token))
        return
      end

      # Check for auto-closing tags (like [*] inside another [*])
      if tag_def.auto_close && current_node.is_a?(Nodes::Tag) && current_node.name == token.content
        pop_stack
      end

      # Check nesting restrictions (if any)
      # For now, just create the node
      node = Nodes::Tag.new(token.content, parse_attributes(token.attributes))

      is_void = tag_def.void
      if tag_def.void_if_attr_present && token.attributes && !token.attributes.strip.empty?
        is_void = true
      end

      if is_void
        # Void tags (like img) don't have children or closing tags
        # Just add to current parent
        current_node.children << node
      else
        # Normal tags get pushed to stack
        current_node.children << node
        @stack << node
      end
    end

    def handle_close_tag(token)
      tag_name = token.content
      tag_def = @config.tags[tag_name]

      # If tag is not defined, treat as text
      unless tag_def
        add_text_node(token_to_text(token))
        return
      end

      # 1. Find if this tag is in the stack
      target_index = @stack.rindex { |node| node.is_a?(Nodes::Tag) && node.name == tag_name }

      # If not found, it's a stray closing tag -> treat as text
      unless target_index
        add_text_node(token_to_text(token))
        return
      end

      # 2. Check priorities of all tags *above* the target in the stack
      #    Stack: [Root, ..., Target, Inter1, Inter2, Top]
      #    We need to check if Target can force-close Inter1 and Inter2.
      
      # We iterate from the node right after target, up to the top
      ((target_index + 1)...@stack.size).each do |i|
        intermediate_node = @stack[i]
        inter_def = @config.tags[intermediate_node.name]
        
        # If the intermediate tag has HIGHER (or equal?) priority, it blocks the closing.
        # Logic: "High-priority container tags ... force-close lower-priority tags"
        # So if Target.priority > Inter.priority, we CAN close.
        # If Target.priority <= Inter.priority, we CANNOT close.
        
        # Note: If priorities are equal, standard BBCode usually implies regular nesting rules apply,
        # so you can't close an outer tag if an inner tag of same priority is open (e.g. [b][b]..[/b][/b]).
        # So strictly: Target must be STRONGER (>) to force close.
        
        if tag_def.priority <= inter_def.priority
          # Blocked! Treat the closing tag as text because we can't reach the target.
          add_text_node(token_to_text(token))
          return
        end
      end

      # 3. If we are here, we are allowed to close.
      #    Pop everything down to (and including) the target.
      while @stack.size > target_index
        pop_stack
      end
    end

    def add_text_node(text)
      # Optimization: Merge with previous text node if possible
      last_child = current_node.children.last
      if last_child.is_a?(Nodes::Text)
        # We need a new Text object or modify existing? 
        # Nodes::Text is immutable-ish in our design? 
        # Let's verify Nodes::Text. 
        # It has attr_reader :content. We should probably modify content string in place if mutable
        # or replace the node.
        # Ruby strings are mutable.
        last_child.content << text
      else
        current_node.children << Nodes::Text.new(text)
      end
    end

    def pop_stack
      @stack.pop
    end

    def parse_attributes(attr_string)
      # Very basic attribute parsing for now.
      # Phase 1 only supports simple attributes like [url=http://...]
      # The Tokenizer gives us the raw string after '='.
      return {} if attr_string.nil? || attr_string.empty?
      
      # For now, we store the "default" attribute (the one in [tag=VALUE]) 
      # as :default key or similar? Or just as the string?
      # Let's store it as :default for now.
      { default: attr_string }
    end

    def token_to_text(token)
      case token.type
      when :open_tag
        attr_part = token.attributes ? "=#{token.attributes}" : ""
        "[#{token.content}#{attr_part}]"
      when :close_tag
        "[/#{token.content}]"
      when :text
        token.content
      end
    end
  end
end
