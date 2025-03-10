module ProseMirror
  module Serializers
    # A blank mark used as a fallback
    BLANK_MARK = {open: "", close: "", mixable: true}.freeze

    # A specification for serializing a ProseMirror document as Markdown/CommonMark text.
    class MarkdownSerializer
      attr_reader :nodes, :marks, :options

      # Default serializers for various node types
      DEFAULT_NODE_SERIALIZERS = {
        blockquote: ->(state, node, parent = nil, index = nil) {
          # Track that we're in a blockquote to handle lists within blockquotes properly
          old_in_blockquote = state.instance_variable_get(:@in_blockquote) || false
          state.instance_variable_set(:@in_blockquote, true)

          # Use the standard blockquote prefix for all content
          state.wrap_block("> ", nil, node) { state.render_content(node) }

          # Restore the blockquote state
          state.instance_variable_set(:@in_blockquote, old_in_blockquote)
        },

        code_block: ->(state, node, parent = nil, index = nil) {
          # Make sure fence is longer than any dash sequence within content
          backticks = node.text_content.scan(/`{3,}/m)
          fence = backticks.empty? ? "```" : (backticks.sort.last + "`")

          state.write(fence + (node.attrs[:params] || "") + "\n")
          state.text(node.text_content, false)
          # Add newline before closing marker
          state.write("\n")
          state.write(fence)
          state.close_block(node)
        },

        heading: ->(state, node, parent = nil, index = nil) {
          state.write(state.repeat("#", node.attrs[:level]) + " ")
          state.render_inline(node, false)
          state.close_block(node)
        },

        horizontal_rule: ->(state, node, parent = nil, index = nil) {
          state.write(node.attrs[:markup] || "---")
          state.close_block(node)
        },

        bullet_list: ->(state, node, parent = nil, index = nil) {
          # Special handling for lists inside blockquotes
          if state.instance_variable_get(:@in_blockquote)
            # For lists in blockquotes, add the blockquote prefix to each line
            # Each list item should start with "> * "
            state.render_list(node, "", ->(_) { "* " }, true)
          else
            # Standard list rendering
            state.render_list(node, "  ", ->(_) { "* " })
          end
        },

        ordered_list: ->(state, node, parent = nil, index = nil) {
          start = node.attrs[:order] || 1

          # Special handling for ordered lists inside blockquotes
          if state.instance_variable_get(:@in_blockquote)
            # For lists in blockquotes, add the blockquote prefix to each line
            # Each list item should start with "> 1. " etc.
            state.render_list(node, "", ->(i) {
              "#{start + i}. "
            }, true)
          else
            # Standard ordered list rendering
            state.render_list(node, "  ", ->(i) {
              "#{start + i}. "
            })
          end
        },

        list_item: ->(state, node, parent = nil, index = nil) {
          # Track that we're processing a list item to handle nested lists
          old_in_list_item = state.instance_variable_get(:@in_list_item) || false
          state.instance_variable_set(:@in_list_item, true)

          # Special handling for list items in blockquotes
          if state.instance_variable_get(:@in_blockquote)
            # Process the list item content with special handling
            node.each_with_index do |child, i|
              if child.type.name == "paragraph"
                # Render paragraph content directly
                state.render_inline(child)
              else
                # Render other content normally
                state.render(child, node, i)
              end
            end
          else
            # Process the list item content normally
            state.render_content(node)
          end

          # Restore the previous state
          state.instance_variable_set(:@in_list_item, old_in_list_item)
        },

        paragraph: ->(state, node, parent = nil, index = nil) {
          # Special handling for paragraphs inside list items to avoid extra whitespace
          if state.instance_variable_get(:@in_list_item)
            # Create a clean paragraph renderer for list items
            old_at_block_start = state.instance_variable_get(:@at_block_start)

            # Render the paragraph content directly with minimal whitespace
            state.render_inline(node)

            # Restore state
            state.instance_variable_set(:@at_block_start, old_at_block_start)
          elsif state.instance_variable_get(:@in_blockquote) && parent&.type&.name == "bullet_list"
            # Special handling for paragraphs in bullet lists inside blockquotes
            old_at_block_start = state.instance_variable_get(:@at_block_start)

            # Render with blockquote prefix
            state.render_inline(node)

            # Restore state
            state.instance_variable_set(:@at_block_start, old_at_block_start)
          else
            # Normal paragraph rendering for non-list items
            state.render_inline(node)
            state.close_block(node)
          end
        },

        image: ->(state, node, parent = nil, index = nil) {
          state.write("![" + state.esc(node.attrs[:alt] || "") + "](" +
                    node.attrs[:src].gsub(/[\(\)]/, "\\\\\\&") +
                    (node.attrs[:title] ? ' "' + node.attrs[:title].gsub('"', '\\"') + '"' : "") +
                    ")")
        },

        hard_break: ->(state, node, parent, index) {
          (index + 1...parent.child_count).each do |i|
            if parent.child(i).type != node.type
              state.write("\\\n")
              return
            end
          end
        },

        text: ->(state, node, parent = nil, index = nil) {
          state.text(node.text, !state.in_autolink)
        },

        # Table serialization support
        table: ->(state, node, parent = nil, index = nil) {
          # Track that we're in a table
          old_in_table = state.instance_variable_get(:@in_table) || false
          state.instance_variable_set(:@in_table, true)

          # Render table content
          state.render_content(node)

          # Restore table state
          state.instance_variable_set(:@in_table, old_in_table)

          # Only add newline if not at the end of the document
          if parent && index < parent.child_count - 1
            state.close_block(node)
          end
        },

        table_row: ->(state, node, parent = nil, index = nil) {
          # Write row separator after headers
          if index == 1 && parent && parent.child(0).content.any? { |cell| cell.type.name == "table_header" }
            state.write("|")
            node.content.each do |_|
              state.write(" --- |")
            end
            state.write("\n")
          end

          # Write row content
          state.write("|")
          state.render_content(node)

          # Add newline unless this is the last row
          if parent && index < parent.child_count - 1
            state.write("\n")
          end
        },

        table_header: ->(state, node, parent = nil, index = nil) {
          state.write(" ")
          # Render content with marks
          node.content.each do |cell_content|
            state.render_inline(cell_content)
          end
          state.write(" |")
        },

        table_cell: ->(state, node, parent = nil, index = nil) {
          state.write(" ")
          # Render content with marks
          node.content.each do |cell_content|
            state.render_inline(cell_content)
          end
          state.write(" |")
        }
      }

      # Default serializers for various mark types
      DEFAULT_MARK_SERIALIZERS = {
        em: {
          open: "*",
          close: "*",
          mixable: true,
          expel_enclosing_whitespace: true
        },

        italic: {
          open: "*",
          close: "*",
          mixable: true,
          expel_enclosing_whitespace: true
        },

        text_style: {
          open: "",
          close: "",
          mixable: true,
          expel_enclosing_whitespace: false
        },

        inline_thread: {
          open: "",
          close: "",
          mixable: true,
          expel_enclosing_whitespace: false
        },

        strong: {
          open: "**",
          close: "**",
          mixable: true,
          expel_enclosing_whitespace: true
        },

        link: {
          open: ->(state, mark, parent, index) {
            state.in_autolink = ProseMirror::Serializers.is_plain_url(mark, parent, index)
            state.in_autolink ? "<" : "["
          },
          close: ->(state, mark, parent, index) {
            in_autolink = state.in_autolink
            state.in_autolink = nil

            if in_autolink
              ">"
            else
              "](" + mark.attrs[:href].gsub(/[\(\)"]/, "\\\\\\&") +
                (mark.attrs[:title] ? ' "' + mark.attrs[:title].gsub('"', '\\"') + '"' : "") + ")"
            end
          },
          mixable: true
        },

        code: {
          open: ->(_, mark, parent, index) { ProseMirror::Serializers.backticks_for(parent.child(index), -1) },
          close: ->(_, mark, parent, index) { ProseMirror::Serializers.backticks_for(parent.child(index - 1), 1) },
          escape: false
        }
      }

      # Constructor with node serializers, mark serializers, and options
      # @param nodes [Hash] Node serializer functions
      # @param marks [Hash] Mark serializer specifications
      # @param options [Hash] Configuration options
      def initialize(nodes, marks, options = {})
        @nodes = nodes
        @marks = marks
        @options = options
      end

      # Serialize the content of the given node to CommonMark
      # @param content [Node] The node to serialize
      # @param options [Hash] Serialization options
      # @return [String] The markdown output
      def serialize(content, options = {})
        options = @options.merge(options)
        state = MarkdownSerializerState.new(@nodes, @marks, options)
        state.render_content(content)
        state.out
      end
    end

    # Helper method for determining backticks for code marks
    def self.backticks_for(node, side)
      ticks = /`+/
      len = 0

      if node.is_text
        node.text.scan(ticks) { |m| len = [len, m.length].max }
      end

      result = (len > 0 && side > 0) ? " `" : "`"
      len.times { result += "`" }
      result += " " if len > 0 && side < 0

      result
    end

    # Determines if a link is a plain URL
    def self.is_plain_url(link, parent, index)
      return false if link.attrs[:title] || !/^\w+:/.match?(link.attrs[:href])

      content = parent.child(index)
      return false if !content.is_text || content.text != link.attrs[:href] || content.marks[content.marks.length - 1] != link

      index == parent.child_count - 1 || !link.is_in_set(parent.child(index + 1).marks)
    end

    # This class is used to track state and expose methods related to markdown serialization
    class MarkdownSerializerState
      attr_accessor :delim, :out, :closed, :in_autolink, :at_block_start, :in_tight_list, :in_blockquote
      attr_reader :nodes, :marks, :options

      # Initialize a new state object
      def initialize(nodes, marks, options)
        @nodes = nodes
        @marks = marks
        @options = options
        @delim = ""
        @out = ""
        @closed = nil
        @in_autolink = nil
        @at_block_start = false
        @in_tight_list = false
        @in_blockquote = false

        @options[:tight_lists] = false if @options[:tight_lists].nil?
        @options[:hard_break_node_name] = "hard_break" if @options[:hard_break_node_name].nil?
      end

      # Flush any pending closing operations
      def flush_close(size = 2)
        if @closed
          @out += "\n" unless at_blank?
          if size > 1
            delim_min = @delim
            trim = /\s+$/.match(delim_min)
            delim_min = delim_min[0...delim_min.length - trim[0].length] if trim

            (1...size).each do
              @out += delim_min + "\n"
            end
          end
          @closed = nil
        end
      end

      # Get mark info by name
      def get_mark(name)
        info = @marks[name.to_sym]
        if !info
          if @options[:strict] != false
            raise "Mark type `#{name}` not supported by Markdown renderer"
          end
          info = BLANK_MARK
        end
        info
      end

      # Wrap a block with delimiters
      def wrap_block(delim, first_delim, node)
        old = @delim
        write(first_delim.nil? ? delim : first_delim)
        @delim += delim
        yield
        @delim = old
        close_block(node)
      end

      # Check if the output ends with a blank line
      def at_blank?
        /(^|\n)$/.match?(@out)
      end

      # Ensure the current content ends with a newline
      def ensure_new_line
        @out += "\n" unless at_blank?
      end

      # Write content to the output
      def write(content = nil)
        flush_close
        @out += @delim if @delim && at_blank?
        @out += content if content
      end

      # Close the block for the given node
      def close_block(node)
        @closed = node
      end

      # Add text to the document
      def text(text, escape = true)
        lines = text.split("\n")
        lines.each_with_index do |line, i|
          write

          # Escape exclamation marks in front of links
          if !escape && line[0] == "[" && /(^|[^\\])!$/.match?(@out)
            @out = @out[0...@out.length - 1] + "\\!"
          end

          @out += escape ? esc(line, @at_block_start) : line
          @out += "\n" if i != lines.length - 1
        end
      end

      # Render a node
      def render(node, parent, index)
        if @nodes[node.type.name.to_sym]
          @nodes[node.type.name.to_sym].call(self, node, parent, index)
        elsif @options[:strict] != false
          raise "Token type `#{node.type.name}` not supported by Markdown renderer"
        elsif !node.type.is_leaf
          if node.type.inline_content
            render_inline(node)
          else
            render_content(node)
          end
          close_block(node) if node.is_block
        end
      end

      # Render the contents of a parent as block nodes
      def render_content(parent)
        parent.each_with_index do |node, i|
          render(node, parent, i)
        end
      end

      # Render inline content
      def render_inline(parent, from_block_start = true)
        @at_block_start = from_block_start
        active = []
        trailing = ""

        progress = lambda do |node, offset, index|
          marks = node ? node.marks : []

          # Remove marks from hard_break that are the last node inside
          # that mark to prevent parser edge cases
          if node && node.type.name == @options[:hard_break_node_name]
            marks = marks.select do |m|
              next false if index + 1 == parent.child_count

              next_node = parent.child(index + 1)
              m.is_in_set(next_node.marks) && (!next_node.is_text || /\S/.match?(next_node.text))
            end
          end

          leading = trailing
          trailing = ""

          # Handle whitespace expelling
          if node && node.is_text && marks.any? { |mark|
            info = get_mark(mark.type.name.to_sym)
            info && info[:expel_enclosing_whitespace] && !mark.is_in_set(active)
          }
            match = /^(\s*)(.*)$/m.match(node.text)
            if match[1] && !match[1].empty?
              leading += match[1]
              node = (match[2] && !match[2].empty?) ? node.with_text(match[2]) : nil
              marks = active if node.nil?
            end
          end

          if node && node.is_text && marks.any? { |mark|
            info = get_mark(mark.type.name.to_sym)
            info && info[:expel_enclosing_whitespace] &&
                (index == parent.child_count - 1 || !mark.is_in_set(parent.child(index + 1).marks))
          }
            match = /^(.*?)(\s*)$/m.match(node.text)
            if match[2] && !match[2].empty?
              trailing = match[2]
              node = (match[1] && !match[1].empty?) ? node.with_text(match[1]) : nil
              marks = active if node.nil?
            end
          end

          inner = (marks.length > 0) ? marks[marks.length - 1] : nil
          no_esc = inner && get_mark(inner.type.name)[:escape] == false
          len = marks.length - (no_esc ? 1 : 0)

          # Try to reorder marks to avoid needless mark recalculation
          i = 0
          while i < len
            mark = marks[i]
            info = get_mark(mark.type.name)
            break unless info[:mixable]

            j = 0
            while j < active.length
              other = active[j]
              info_other = get_mark(other.type.name)
              break unless info_other[:mixable]

              if mark.eq(other)
                if i > j
                  marks = marks[0...j] + [mark] + marks[j...i] + marks[(i + 1)...len]
                elsif j > i
                  marks = marks[0...i] + marks[(i + 1)...j] + [mark] + marks[j...len]
                end
                break
              end
              j += 1
            end
            i += 1
          end

          # Find the prefix of the mark set that didn't change
          keep = 0
          while keep < [active.length, len].min && active[keep].eq(marks[keep])
            keep += 1
          end

          # Close marks that no longer apply
          (active.length - 1).downto(keep) do |i|
            info = get_mark(active[i].type.name)
            text = info[:close]
            text = text.call(self, active[i], parent, index) if text.is_a?(Proc)
            write(text)
          end

          text = leading
          active.slice!(keep, active.length)

          # Output any previously expelled trailing whitespace
          if text && leading.length > 0
            @out += text
          end

          # Open marks that are new now
          (keep...len).each do |i|
            info = get_mark(marks[i].type.name)
            text = info[:open]
            text = text.call(self, marks[i], parent, index) if text.is_a?(Proc)
            write(text)
            active.push(marks[i])
          end

          # Render the node
          if node
            write
            if no_esc
              render(node, parent, index)
            else
              text = node.text
              if node.is_text
                write(esc(text, @at_block_start))
              else
                render(node, parent, index)
              end
            end
          end

          @at_block_start = false
        end

        (0...parent.child_count).each do |i|
          progress.call(parent.child(i), 0, i)
        end
        progress.call(nil, 0, parent.child_count)
      end

      # Render a list
      def render_list(node, indent, marker_gen, in_blockquote = false)
        # Clear any closed block
        if @closed && @closed.type == node.type
          @closed = nil
        else
          ensure_new_line
        end

        # Remember current indentation level
        old_indent = @delim
        is_nested = !old_indent.empty?

        # Set up tight list handling
        old_tight = @in_tight_list
        @in_tight_list = node.attrs[:tight]

        # Process each list item
        node.each_with_index do |child, i|
          # For blockquote lists, add the blockquote prefix
          @delim = if in_blockquote
            "> "
          # For nested lists, add standard indentation
          elsif is_nested
            "    "
          else
            ""
          end

          # Write the marker with proper spacing
          write(marker_gen.call(i))

          # Store the current position after the marker
          old_delim = @delim

          # Add exactly one space after the marker for content
          @delim = old_delim + " "

          # Render the item's content
          render(child, node, i)

          # Restore delimiter for next item
          @delim = old_delim

          # Add a newline after each list item unless it's the last one
          unless i == node.child_count - 1
            ensure_new_line
          end
        end

        # Restore the tight list setting
        @in_tight_list = old_tight

        # Restore the original indentation
        @delim = old_indent

        # Handle spacing between list items and the next content
        size = (@closed && @closed.type.name == "paragraph" && !node.attrs[:tight]) ? 2 : 1
        flush_close(size)
      end

      # Escape Markdown characters
      def esc(str, start_of_line = false)
        str = str.gsub(/[`*\\~\[\]_]/) { |m| "\\" + m }
        if start_of_line
          str = str.gsub(/^[#\-*+>]/) { |m| "\\" + m }
            .gsub(/^(\d+)\./) { |match, d| d.to_s + "\\." }
        end
        str.gsub("![", "\\![")
      end

      # Repeat a string n times
      def repeat(str, n)
        str * n
      end
    end
  end
end
