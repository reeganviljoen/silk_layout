# frozen_string_literal: true

require "crass"

module SilkLayout
  module CSS
    class Parser
      attr_reader :rules, :page_rules

      def self.parse_all(stylesheets, media: :print)
        parse_stylesheets(stylesheets, media: media).rules
      end

      def self.parse_page_rules(stylesheets, media: :print)
        parse_stylesheets(stylesheets, media: media).page_rules
      end

      def self.parse_stylesheets(stylesheets, media: :print)
        parser = new(media: media)

        stylesheets.each do |css|
          parser.parse_nodes(Crass.parse(css))
        end

        parser
      end

      def initialize(media:)
        @media = media.to_s.downcase
        @rules = []
        @page_rules = []
        @order = 0
        @page_order = 0
      end

      def parse_nodes(nodes)
        nodes.each do |node|
          case node[:node]
          when :style_rule
            append_style_rules(node)
          when :at_rule
            append_at_rule(node)
          end
        end
      end

      private

      def append_at_rule(node)
        case node[:name].to_s.downcase
        when "media"
          parse_nodes(Crass.parse(tokens_to_css(node[:block]))) if media_matches?(node[:prelude])
        when "page"
          append_page_rule(node) if print_media?
        end
      end

      def append_style_rules(node)
        selector_text = node[:selector][:value].to_s.strip
        selectors = selector_text.split(",").map(&:strip).reject(&:empty?)
        declarations = declarations_from_children(node[:children])

        selectors.each do |raw_selector|
          selector = Selector.new(raw_selector)

          rules << Rule.new(
            selector: selector,
            declarations: declarations,
            specificity: selector.specificity,
            order: @order,
            origin: :author
          )

          @order += 1
        end
      end

      def append_page_rule(node)
        declarations = declarations_from_block(node[:block])
        return if declarations.empty?

        page_rules << PageRule.new(
          selector: tokens_to_css(node[:prelude]).strip,
          declarations: declarations,
          order: @page_order
        )

        @page_order += 1
      end

      def declarations_from_children(children)
        children.each_with_object([]) do |child, declarations|
          next unless child[:node] == :property

          declarations << declaration_for(child)
        end
      end

      def declarations_from_block(block)
        declarations_from_children(Crass.parse_properties(tokens_to_css(block)))
      end

      def declaration_for(node)
        [
          node[:name].to_s.downcase,
          Declaration.new(value: node[:value].to_s.strip, important: node[:important] ? true : false)
        ]
      end

      def media_matches?(prelude)
        tokens_to_css(prelude).split(",").any? do |query|
          media_query_matches?(query)
        end
      end

      def media_query_matches?(query)
        raw = query.to_s.strip.downcase
        return false if raw.empty?

        raw = raw.sub(/\Aonly\s+/, "")
        negated = raw.start_with?("not ")
        raw = raw.sub(/\Anot\s+/, "") if negated

        media_type = raw[/\A[a-z][a-z0-9_-]*/]
        matched = media_type.nil? || media_type == "all" || media_type == @media

        negated ? !matched : matched
      end

      def print_media?
        @media == "print" || @media == "all"
      end

      def tokens_to_css(tokens)
        Array(tokens).map { |token| token_to_css(token) }.join
      end

      def token_to_css(token)
        return token[:tokens].map { |child| token_to_css(child) }.join if token[:tokens]

        token[:raw].to_s
      end
    end
  end
end
