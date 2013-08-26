# -*- coding: utf-8 -*
# --
# The MIT License (MIT)
#
# Copyright (C) 2013 Gitorious AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++
module JustPaginate

  VERSION = "0.1.1"

  # TODO make sure negative numbers, non-integers etc are just converted to page 1.
  def self.page_value(page)
    if page.nil?
      1
    else
      page.to_i
    end
  end

  def self.paginate(curr_page, per_page, total_entry_count,  &selection_strategy)
    raise "Pagination just supplies index range, expects a selection strategy" if selection_strategy.nil?

    entries = yield(index_range(curr_page, per_page, total_entry_count)) || []
    return entries, total_page_number(total_entry_count, per_page)
  end

  def self.total_page_number(total_entry_count, per_page)
    (total_entry_count.to_f / per_page).ceil
  end

  def self.index_range(curr_page, per_page, total_entry_count)
    start_index = ((curr_page-1)*per_page)
    end_index = (start_index+per_page)-1

    if total_entry_count == 0
      return 0..0
    end

    if(start_index>(total_entry_count-1))
      start_index = total_entry_count-per_page
      end_index = total_entry_count-1
    end

    if end_index>total_entry_count
      end_index = total_entry_count
    end

    Range.new(start_index, end_index)
  end

  def self.page_out_of_bounds?(curr_page, per_page, total_entry_count)
    if curr_page < 1
      true
    else
      start_index = ((curr_page-1)*per_page)
      end_index = (start_index+per_page)-1
      start_index > total_entry_count
    end
  end

  def self.page_navigation(curr_page, total_page_count, &page_link_constructor)
    links = page_links(curr_page.to_i, total_page_count, &page_link_constructor)
    if total_page_count > 1
      "<div class='pagination'><ul>#{links}</ul></div>"
    else
      ""
    end
  end

  # Depends on Bootstrap styling/widgets
  def self.page_links(curr_page, total_page_count, &page_link_constructor)
    page_labels(curr_page, total_page_count).map do |label|
      page_element = ""

      if label == "..."
        page_element = "<li class='disabled'><a>#{label}</a></li>"
      elsif label == "<"
        page_url = yield(curr_page-1)
        page_element = "<li><a rel='prev' href='#{page_url}'>#{label}</a></li>"
      elsif label == ">"
        page_url = yield(curr_page+1)
        page_element = "<li><a rel='next' href='#{page_url}'>#{label}</a></li>"
      else
        page_url = yield(label)
        if label.to_i == curr_page
          page_element = "<li class='active'><a>#{label}</a></li>"
        else
          page_element = "<li><a href='#{page_url}'>#{label}</a></li>"
        end
      end

    end.join(" ")
  end

   # Not dependent on bootstrap styling/widgets
  def self.page_navigation_non_bootstrap(curr_page, total_page_count, &page_link_constructor)
    if total_page_count > 1
      links = page_links_non_bootstrap(curr_page.to_i, total_page_count, &page_link_constructor)
      return "<div class='pagination'>#{links}</div>"
    else
      ""
    end
  end

  # Not dependent on bootstrap styling/widgets
  def self.page_links_non_bootstrap(curr_page, total_page_count, &page_link_constructor)
    page_labels(curr_page, total_page_count).map do |label|
      page_element = ""

      if label == "..."
        page_element = "<span class='gap'>#{label}</span>"
      elsif label == "<"
        page_url = yield(curr_page-1)
        page_element = "<a rel='prev' href='#{page_url}'>#{label}</a>"
      elsif label == ">"
        page_url = yield(curr_page+1)
        page_element = "<a rel='next' href='#{page_url}'>#{label}</a>"
      else
        page_url = yield(label)
        if label.to_i == curr_page
          page_element = "<span class='current'>#{label}</span>"
        else
          page_element = "<a href='#{page_url}'>#{label}</a>"
        end
      end

    end.join(" ")
  end

  def self.page_labels(current, total)
    max_visible = 10
    labels = []

    if total <= max_visible
      1.upto(total).each {|n| labels.push(n.to_s)}
    else
      if current > max_visible
        labels = ["<", "1", "..."]
      else
        current = 1
      end

      if (current > (total-max_visible))
        current = (total-max_visible)+1
      end

      current.upto(current+(max_visible-1)).each {|n| labels.push(n.to_s)}

      if (current <= (total-max_visible))
        labels.concat ["...", "#{total}", ">"]
      end
    end

    return labels
  end

end
