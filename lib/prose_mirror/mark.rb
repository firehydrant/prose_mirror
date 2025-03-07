module ProseMirror
  # Represents a mark in a ProseMirror document
  # Marks can be applied to nodes to indicate formatting or other attributes
  class Mark
    attr_reader :type, :attrs

    # Create a new Mark
    # @param type [String] The mark type name (e.g., "strong", "em", "link")
    # @param attrs [Hash] Mark attributes
    def initialize(type, attrs = {})
      @type = OpenStruct.new(name: type)
      @attrs = attrs
    end

    # Check if this mark is equal to another mark
    # Two marks are equal if they have the same type name
    # @param other [Mark] The other mark to compare with
    # @return [Boolean] true if the marks are equal, false otherwise
    def eq(other)
      @type.name == other.type.name
    end

    # Check if this mark is in the given set of marks
    # @param mark_array [Array<Mark>] The array of marks to check against
    # @return [Boolean] true if the mark is in the set, false otherwise
    def is_in_set(mark_array)
      mark_array.any? { |m| eq(m) }
    end
  end
end
