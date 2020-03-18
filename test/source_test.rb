require_relative "test_helper"

module Nanoc
  module Github
    class SourceTest < Minitest::Test
      def site_config
        Nanoc::Core::Configuration.new(hash: {}, dir: "/dummy")
      end

      def source_with_posts
        Source.new(site_config, nil, nil, {
          repository: "pawelpacana/test-source",
          path:       "posts"
        })
      end

      def empty_source
        Source.new(site_config, nil, nil, {
          repository: "pawelpacana/test-empty",
        })
      end

      def test_identifier
        assert_equal :github, source_with_posts.class.identifier
      end

      def test_items
        VCR.use_cassette("test_items") do
          assert_kind_of Array, source_with_posts.items
          refute source_with_posts.items.empty?
        end
      end

      def test_no_items
        VCR.use_cassette("test_no_items") do
          assert_kind_of Array, empty_source.items
          assert empty_source.items.empty?
        end
      end

      def test_item
        VCR.use_cassette("test_item") do
          item = source_with_posts.items[0]

          assert_kind_of Nanoc::Core::Item, item
          assert_equal Nanoc::Identifier.new("/post.md"), item.identifier
          assert_equal <<~EOC, item.content.string
            # Title

            Some content.
          EOC
          assert_equal ({}), item.attributes
        end
      end
    end
  end
end
