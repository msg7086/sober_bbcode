module SoberBBCode
  module Nodes
    # Base node class
    class Node; end

    # Represents text content
    class Text < Node
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def ==(other)
        other.is_a?(Text) && content == other.content
      end
    end

    # Represents a BBCode tag
    class Tag < Node
      attr_reader :name, :attributes, :children

      def initialize(name, attributes = {}, children = [])
        @name = name
        @attributes = attributes
        @children = children
      end

      def ==(other)
        other.is_a?(Tag) &&
          name == other.name &&
          attributes == other.attributes &&
          children == other.children
      end
    end

    # Represents the root of the AST
    class Root < Node
      attr_reader :children

      def initialize(children = [])
        @children = children
      end

      def ==(other)
        other.is_a?(Root) && children == other.children
      end
    end
  end
end
