module ProseMirror
  # Represents a node in a ProseMirror document
  # This can be a block node (paragraph, heading), inline node, or a text node
  class Node
    attr_reader :type, :attrs, :content, :marks, :text

    # Create a new Node
    # @param type [String] The node type name
    # @param attrs [Hash] Node attributes
    # @param content [Array<Node>] Child nodes
    # @param marks [Array<Mark>] Node marks
    # @param text [String, nil] Text content for text nodes, nil otherwise
    def initialize(type, attrs = {}, content = [], marks = [], text = nil)
      @type = OpenStruct.new(
        name: type,
        is_block: true,
        is_leaf: content.empty? && !text,
        inline_content: !!text
      )
      @attrs = attrs
      @content = content
      @marks = marks
      @text = text
    end

    # Check if this is a text node
    # @return [Boolean] true if this is a text node, false otherwise
    def is_text
      !@text.nil?
    end

    # Check if this is a block node
    # @return [Boolean] true if this is a block node, false otherwise
    def is_block
      @type.is_block
    end

    # Get the text content of this node
    # For text nodes, returns the text directly
    # For non-text nodes, returns the concatenated text content of all child nodes
    # @return [String] The text content
    def text_content
      is_text ? @text : @content.map(&:text_content).join("")
    end

    # Get the number of child nodes
    # @return [Integer] The number of child nodes
    def child_count
      @content.length
    end

    # Get a child node at the specified index
    # @param index [Integer] The index of the child node to retrieve
    # @return [Node, nil] The child node, or nil if not found
    def child(index)
      @content[index]
    end

    # Get the size of this node
    # For text nodes, returns the text length
    # For other nodes, returns 1
    # @return [Integer] The node size
    def node_size
      @text ? @text.length : 1
    end

    # Iterate over each child node with its index
    # @yield [node, index] Yields each child node and its index
    # @yieldparam node [Node] The child node
    # @yieldparam index [Integer] The index of the child node
    def each_with_index(&block)
      @content.each_with_index(&block)
    end

    # Create a new text node with the given text but same marks
    # @param new_text [String] The new text content
    # @return [Node] A new text node with the same marks but different text
    def with_text(new_text)
      Node.new(@type.name, @attrs, [], @marks, new_text)
    end
  end
end
