require 'cgi'

module SoberBBCode
  class Compiler
    def initialize(root)
      @root = root
      @config = SoberBBCode.configuration
    end

    def to_html
      visit(@root)
    end

    private

    def visit(node, parent_tag_name = nil)
      case node
      when Nodes::Root
        node.children.map { |child| visit(child, nil) }.join
      when Nodes::Text
        content = CGI.escapeHTML(node.content)
        
        # Handle newlines based on context
        if ['code', 'pre'].include?(parent_tag_name)
          content
        elsif ['ul', 'ol', 'table', 'tr', 'td'].include?(parent_tag_name)
          # In lists, we typically ignore pure whitespace between items
          # But if it's mixed content, we might keep it.
          # For now, let's just strip leading/trailing whitespace if it's purely whitespace?
          # Or, if it's just a newline, ignore it?
          # Standard HTML lists ignore whitespace between <li>.
          # If the text node is purely whitespace, ignore it.
          if content.strip.empty?
            ""
          else
            content
          end
        else
          # Convert newlines to <br> for regular text
          content.gsub("\n", "<br>")
        end
      when Nodes::Tag
        render_tag(node, parent_tag_name)
      end
    end

    def render_tag(node, parent_tag_name)
      tag_def = @config.tags[node.name]
      return "" unless tag_def # Should not happen given Parser logic

      # Special handling for orphan list items
      if node.name == 'li' && !['ul', 'ol'].include?(parent_tag_name)
        # Render children only, stripping the <li> tag
        return node.children.map { |child| visit(child, node.name) }.join
      end

      if node.name == 'img'
        return render_image(node)
      end

      if node.name == 'markdown'
        raw_content = node.children.map(&:content).join
        return @config.markdown_renderer.call(raw_content)
      end

      html_name = tag_def.html_tag
      attributes_str = render_attributes(node, tag_def)

      is_void = tag_def.html_void
      
      if is_void
        "<#{html_name}#{attributes_str}>"
      else
        children_html = node.children.map { |child| visit(child, node.name) }.join
        if node.name == 'table'
          children_html = "<tbody>#{children_html}</tbody>"
        end
        "<#{html_name}#{attributes_str}>#{children_html}</#{html_name}>"
      end
    end

    def render_image(node)
      src = node.attributes[:default]
      
      # If no attribute, try to get from children (content)
      if (src.nil? || src.empty?)
        # We only take text nodes to avoid rendering tags inside src
        src = node.children.select { |c| c.is_a?(Nodes::Text) }.map(&:content).join
      end

      return "" if src.nil? || src.strip.empty?
      
      # Security check
      return "" if src.strip.downcase.start_with?('javascript:')

      # The content was consumed as src, so don't render children
      "<img src=\"#{CGI.escapeHTML(src)}\">"
    end

    def render_attributes(node, tag_def)
      # Currently only supporting 'default' attribute from [tag=value]
      return "" if node.attributes.empty?

      default_val = node.attributes[:default]
      return "" if default_val.nil? || default_val.empty?

      # Special handling for align tag
      if tag_def.name == 'align'
        return " style=\"text-align: #{CGI.escapeHTML(default_val)};\""
      end

      # Special handling for size tag
      if tag_def.name == 'size'
        return handle_size_attribute(default_val)
      end

      # Map to the first allowed attribute defined in configuration
      target_attr = tag_def.attributes.first
      return "" unless target_attr

      # Security check for URLs
      if (tag_def.name == 'url' || target_attr == :src || target_attr == :href) && 
         default_val.strip.downcase.start_with?('javascript:')
        return "" # Omit unsafe attribute
      end

      " #{target_attr}=\"#{CGI.escapeHTML(default_val)}\""
    end

    def handle_size_attribute(value)
      size = value.to_f
      return "" if size <= 0

      formatted_size = (size % 1).zero? ? size.to_i : size

      font_size = if size >= 1 && size <= 3
                    "#{formatted_size}em"
                  elsif size >= 10 && size <= 30
                    "#{formatted_size}pt"
                  elsif size >= 50 && size <= 300
                    "#{formatted_size}%"
                  else
                    "2em"
                  end
      
      " style=\"font-size: #{font_size};\""
    end
  end
end
