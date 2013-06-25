require File.dirname(__FILE__) + '/test_helper.rb'

class JustPaginateTest < Test::Unit::TestCase

  context "The backend pagination function" do
    should "basically work like this" do
      paged_collection = [1,2,3,4,5,6,7,8,9,10]

      entries, page_count = JustPaginate.paginate(1, 5, 100) do |index_range|
        paged_collection.slice(index_range)
      end

      assert_equal 5, entries.size
      assert_equal 20, page_count
      assert_equal [1,2,3,4,5], entries
    end

    should "blow up if no selection strategy block is present" do
      assert_raises RuntimeError do
        JustPaginate.paginate(1, 20, 100)
      end
    end

    should "provide predicate to check if pagination would exceed total pagecount" do
      assert JustPaginate.page_out_of_bounds?(7,2,4)
      assert !JustPaginate.page_out_of_bounds?(1,20,100)
    end

    should "state that pages below page 1 are out of bounds" do
      assert JustPaginate.page_out_of_bounds?(-2,2,4)
      assert JustPaginate.page_out_of_bounds?(-1,2,4)
      assert JustPaginate.page_out_of_bounds?(0,2,4)
    end

    should "calculate correct total page count" do
      assert_equal 25, JustPaginate.total_page_number(500, 20)
      assert_equal 25, JustPaginate.total_page_number(498, 20)
    end

    should "correctly apply the supplied selection strategy" do
      ran = false
      sliced_entries, page_count = JustPaginate.paginate(1, 5, 10) do |index_range|
        assert index_range.class == Range
        assert_equal 0..4, index_range
        ran = true
      end
      assert ran, "selection block didn't run"
    end

    should "calculate correct index ranges" do
      assert_equal 0..1, JustPaginate.index_range(1,2,4)
      assert_equal 2..3, JustPaginate.index_range(2,2,4)

      assert_equal 0..2, JustPaginate.index_range(1,3,9)
      assert_equal 3..5, JustPaginate.index_range(2,3,9)
      assert_equal 6..8, JustPaginate.index_range(3,3,9)

      assert_equal 0..2, JustPaginate.index_range(1,3,9)
      assert_equal 3..5, JustPaginate.index_range(2,3,9)
      assert_equal 6..8, JustPaginate.index_range(3,3,9)

      assert_equal 0..19, JustPaginate.index_range(1,20,100)
      assert_equal 60..79, JustPaginate.index_range(4,20,100)
      assert_equal 60..79, JustPaginate.index_range(4,20,95)
      assert_equal 80..99, JustPaginate.index_range(5,20,100)
      assert_equal 80..95, JustPaginate.index_range(5,20,95)

      assert_equal 460..479, JustPaginate.index_range(24,20,500)
      assert_equal 480..499, JustPaginate.index_range(25,20,500)
    end
  end

  should "just fall back to largest possible page if given page extends past collection bounds" do
    assert_equal 2..3, JustPaginate.index_range(2,2,4)
    assert_equal 2..3, JustPaginate.index_range(3,2,4)
    assert_equal 2..3, JustPaginate.index_range(4,2,4)
  end

  should "return 0-0 range for empty collection" do
     assert_equal 0..0, JustPaginate.index_range(2,2,0)
  end

  context "The frontend pagination html helper" do
    should "basically work like this" do
      generated = JustPaginate.page_navigation(1, 10) { |page_no| "/projects/index?page=#{page_no}" }
      # TODO write this and following tests after I've manually browser-reload-iterated something stable'
    end

    should "do page nav labels, truncation and quicklinks correctly" do
      assert_correct_paging_labels "1 2 3 4 5 6 7 8 9 10", 1, 10

      assert_correct_paging_labels "1 2 3 4 5 6 7 8 9 10 ... 50 >", 1, 50
      assert_correct_paging_labels "1 2 3 4 5 6 7 8 9 10 ... 50 >", 5, 50
      assert_correct_paging_labels "1 2 3 4 5 6 7 8 9 10 ... 50 >", 10, 50
      assert_correct_paging_labels "1 2 3 4 5 6 7 8 9 10 ... 545 >", 1, 545

      assert_correct_paging_labels "< 1 ... 11 12 13 14 15 16 17 18 19 20 ... 50 >", 11, 50
      assert_correct_paging_labels "< 1 ... 12 13 14 15 16 17 18 19 20 21 ... 50 >", 12, 50
      assert_correct_paging_labels "< 1 ... 21 22 23 24 25 26 27 28 29 30 ... 50 >", 21, 50
      assert_correct_paging_labels "< 1 ... 40 41 42 43 44 45 46 47 48 49 ... 50 >", 40, 50

      assert_correct_paging_labels "< 1 ... 41 42 43 44 45 46 47 48 49 50", 41, 50
      assert_correct_paging_labels "< 1 ... 41 42 43 44 45 46 47 48 49 50", 45, 50
      assert_correct_paging_labels "< 1 ... 41 42 43 44 45 46 47 48 49 50", 50, 50

      assert_correct_paging_labels "< 1 ... 16 17 18 19 20 21 22 23 24 25", 24, 25
      assert_correct_paging_labels "< 1 ... 16 17 18 19 20 21 22 23 24 25", 25, 25
    end
  end

  def assert_correct_paging_labels(expected_joined, page, total)
    p = JustPaginate
    actual = p.page_labels(page, total).join(" ")
    assert_equal expected_joined, actual, "labels didn't match expected paging labels'"
  end

end
