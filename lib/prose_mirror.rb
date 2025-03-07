require "json"
require "ostruct"
require "active_support/core_ext/string/inflections" # For underscore

# Require all ProseMirror components
require_relative "prose_mirror/version"
require_relative "prose_mirror/node"
require_relative "prose_mirror/mark"
require_relative "prose_mirror/converter"
require_relative "prose_mirror/serializers/markdown_serializer"

# ProseMirror module serves as the namespace for all ProseMirror components
module ProseMirror
  # Helper functions can be added here if needed

  # Convert a JSON ProseMirror document to a ProseMirror::Node tree
  # @param json_string [String] The JSON string representation of a ProseMirror document
  # @return [ProseMirror::Node] The root node of the document
  def self.parse(json_string)
    Converter.from_json(json_string)
  end

  # Convert a ProseMirror::Node to Markdown
  # @param node [ProseMirror::Node] The root node of the document
  # @param options [Hash] Optional serialization options
  # @return [String] The markdown representation
  def self.to_markdown(node, options = {})
    serializer = Serializers::MarkdownSerializer.new(
      Serializers::MarkdownSerializer::DEFAULT_NODE_SERIALIZERS,
      Serializers::MarkdownSerializer::DEFAULT_MARK_SERIALIZERS,
      options
    )
    serializer.serialize(node)
  end
end
