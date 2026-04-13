require 'cgi'

module SoberBBCode
  module MarkdownRenderer
    def self.render(text)
      # 1. Escape HTML for security
      content = CGI.escapeHTML(text)

      # 2. Process line-based elements (Headers and HR)
      lines = content.split("\n").map do |line|
        process_line(line)
      end

      # 3. Process inline elements (Links and Images) across the whole content
      result = lines.join("\n")
      process_inline(result)
    end

    private

    def self.process_line(line)
      # Headers: # Title, ## Title, etc.
      if line =~ /^(#+)\s+(.+)$/
        level = $1.length
        content = $2
        level = 6 if level > 6
        "<h#{level}>#{content}</h#{level}>"
      # HR: ---, ***, ___
      elsif line =~ /^(\s*[-*_]){3,}\s*$/
        "<hr>"
      else
        line
      end
    end

    def self.process_inline(text)
      # Images: ![alt](url)
      # Regex: !\[([^\]]*)\]\(([^)]+)\)
      text = text.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do
        alt = $1
        src = $2
        # Basic security check for src
        if src.strip.downcase.start_with?('javascript:')
          "![#{alt}](#{src})"
        else
          "<img src=\"#{src}\" alt=\"#{alt}\">"
        end
      end

      # Links: [text](url)
      # Regex: \[([^\]]+)\]\(([^)]+)\)
      text = text.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
        label = $1
        url = $2
        # Basic security check for url
        if url.strip.downcase.start_with?('javascript:')
          "[#{label}](#{url})"
        else
          "<a href=\"#{url}\">#{label}</a>"
        end
      end

      text
    end
  end
end
