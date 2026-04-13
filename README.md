# SoberBBCode

## Usage

```ruby
require 'sober_bbcode'

# Basic rendering
html = SoberBBCode.render("[b]Hello World[/b]")
# => "<strong>Hello World</strong>"
```

```ruby
require 'kramdown'

SoberBBCode.configure do |config|
  # config.markdown_renderer should be a proc that accepts text and returns HTML
  config.markdown_renderer = ->(text) { Kramdown::Document.new(text).to_html }
end
```
