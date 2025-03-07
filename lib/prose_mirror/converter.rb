module ProseMirror
  # Converter for transforming between ProseMirror JSON and Node objects
  class Converter
    # Convert a JSON ProseMirror document into Ruby Node objects
    # @param json_string [String] The JSON string representation of a ProseMirror document
    # @return [Node] The root node of the document
    def self.from_json(json_string)
      data = JSON.parse(json_string)
      parse_node(data)
    end

    private

    # Recursively parse nodes from JSON data
    # @param node_data [Hash] The node data from JSON
    # @return [Node] The parsed node
    def self.parse_node(node_data)
      type = node_data["type"]
      attrs = parse_attrs(node_data["attrs"] || {})
      marks = parse_marks(node_data["marks"] || [])

      if type == "text"
        # Text nodes have text content directly
        Node.new(type, attrs, [], marks, node_data["text"])
      else
        # Non-text nodes have child content
        content = (node_data["content"] || []).map { |child| parse_node(child) }
        Node.new(type, attrs, content, marks)
      end
    end

    # Parse attributes from JSON to Ruby hash with symbol keys
    # @param attrs_data [Hash] The attributes data from JSON
    # @return [Hash] Hash with symbol keys
    def self.parse_attrs(attrs_data)
      result = {}
      attrs_data.each do |key, value|
        result[key.to_sym] = value
      end
      result
    end

    # Parse marks from JSON to Ruby Mark objects
    # @param marks_data [Array] The marks data array from JSON
    # @return [Array<Mark>] Array of Mark objects
    def self.parse_marks(marks_data)
      marks_data.map do |mark_data|
        Mark.new(mark_data["type"], parse_attrs(mark_data["attrs"] || {}))
      end
    end
  end
end
