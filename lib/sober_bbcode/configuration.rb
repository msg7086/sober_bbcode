module SoberBBCode
  class Configuration
    attr_reader :tags
    attr_accessor :markdown_renderer

    TagDefinition = Struct.new(
      :name,
      :html_tag,
      :priority,
      :void,
      :void_if_attr_present,
      :html_void,
      :attributes,
      :allow_nesting,
      :raw,
      :auto_close,
      keyword_init: true
    )

    def initialize
      @tags = {}
      @markdown_renderer = ->(text) { SoberBBCode::MarkdownRenderer.render(text) }
      add_default_tags
    end

    def add_tag(name, **options)
      name = name.to_s.downcase
      default_options = {
        name: name,
        html_tag: name,
        priority: 0,
        void: false,
        void_if_attr_present: false,
        html_void: false,
        attributes: [],
        allow_nesting: true,
        raw: false,
        auto_close: false
      }
      @tags[name] = TagDefinition.new(default_options.merge(options))
    end

    private

    def add_default_tags
      # Inline styles
      add_tag :b, html_tag: 'strong'
      add_tag :i, html_tag: 'em'
      add_tag :u, html_tag: 'u'
      add_tag :s, html_tag: 'del'
      add_tag :size, html_tag: 'span', attributes: [:style]
      add_tag :color, html_tag: 'span', attributes: [:style]
      add_tag :font, html_tag: 'span', attributes: [:style]

      # Links and Images
      add_tag :url, html_tag: 'a', attributes: [:href]
      add_tag :img, html_tag: 'img', void: false, void_if_attr_present: true, html_void: true, attributes: [:src, :alt]

      # Blocks
      add_tag :quote, html_tag: 'blockquote', priority: 1
      add_tag :code, html_tag: 'pre', priority: 1
      add_tag :center, html_tag: 'div', priority: 1 # Often styled with class or style
      add_tag :left, html_tag: 'div', priority: 1
      add_tag :right, html_tag: 'div', priority: 1

      # Lists
      add_tag :ul, html_tag: 'ul', priority: 1
      add_tag :ol, html_tag: 'ol', priority: 1
      add_tag :li, html_tag: 'li', priority: 0
      add_tag :list, html_tag: 'ul', priority: 1
      add_tag :'*', html_tag: 'li', priority: 0, auto_close: true

      # Headings
      add_tag :h1, html_tag: 'h1', priority: 1
      add_tag :h2, html_tag: 'h2', priority: 1
      add_tag :h3, html_tag: 'h3', priority: 1
      add_tag :h4, html_tag: 'h4', priority: 1

      # Divider
      add_tag :hr, html_tag: 'hr', void: true, html_void: true

      # Alignment
      add_tag :align, html_tag: 'div', priority: 1, attributes: [:style]

      # Markdown
      add_tag :markdown, raw: true, priority: 1

      # Tables
      add_tag :table, html_tag: 'table', priority: 1
      add_tag :tr, html_tag: 'tr'
      add_tag :td, html_tag: 'td'
    end
  end
end
