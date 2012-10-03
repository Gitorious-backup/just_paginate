# -*- coding: utf-8 -*-
module JustPaginate

  VERSION = "0.0.3"

  def self.page_value(page)
    if page.nil?
      1
    else 
      page.to_i
    end
  end

  def self.paginate(curr_page, per_page, total_entry_count,  &selection_strategy)
    raise "Pagination just supplies index range, expects a selection strategy" if selection_strategy.nil? 
    total_page_number = total_entry_count / per_page
    entries = yield(index_range(curr_page, per_page, total_entry_count)) || []    
    return entries, total_page_number
  end
  
  def self.index_range(curr_page, per_page, total_entry_count)
    start_index = ((curr_page-1)*per_page)
    end_index = (start_index+per_page)-1
    
    if(start_index>total_entry_count)
      raise "Pagination is out of bounds, beyond total entry size"
    end
    
    if end_index>total_entry_count
      end_index=(total_entry_count-1)
    end
    
    Range.new(start_index, end_index)
  end

  def self.page_navigation(curr_page, total_page_count, &page_link_constructor)   
    links = page_links(curr_page.to_i, total_page_count, &page_link_constructor)
    return "<div class='pagination'>#{links}</div>"
  end

# Create gitorous-style-pagination until we move to Bootstrap
# <div class="pagination">
# <a href="/projects?page=24" class="prev_page" rel="prev">Previous</a> 
# <a href="/projects?page=1" rel="start">1</a> 
# <span class="gap">…</span> 
# <a href="/projects?page=21">21</a> 
# <a href="/projects?page=22">22</a> 
# <a href="/projects?page=23">23</a> 
# <a href="/projects?page=24" rel="prev">24</a> <span class="current">25</span> 
# <a href="/projects?page=26" rel="next">26</a> 
# <a href="/projects?page=27">27</a> 
# <a href="/projects?page=28">28</a> 
# <a href="/projects?page=29">29</a> 
# <span class="gap">…</span> 
# <a href="/projects?page=1446">1446</a> 
# <a href="/projects?page=26" class="next_page" rel="next">Next</a>
# </div>


  def self.page_links(curr_page, total_page_count, &page_link_constructor)
    page_labels(curr_page, total_page_count).map do |label|
      page_element = ""
      
      if label == "..."
        page_element = "<span class='gap'>#{label}</span>"
      elsif label == "<"
        page_url = yield(curr_page-1)
        page_element = "<a class='prev_page' rel='prev' href='#{page_url}'>#{label}</a>"
      elsif label == ">"
        page_url = yield(curr_page+1)
        page_element = "<a class='next_page' rel='next' href='#{page_url}'>#{label}</a>"
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
