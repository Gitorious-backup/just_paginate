require "just_paginate/version"
require "just_paginate/common"

module JustPaginate

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
    return "<style>.pagelink{font-size: 20px; margin-right: 5px;}</style><center>#{links}</center>"
  end

  def self.page_links(curr_page, total_page_count, &page_link_constructor)
    page_labels(curr_page, total_page_count).map do |label|        
      page_element = ""
      
      if label == "..."
        page_element = "<span class='pagelink'>#{label}</span>"
      elsif label == "<"
        page_url = yield(curr_page-1)
        page_element = "<a class='pagelink' href='#{page_url}'>#{label}</a>"
      elsif label == ">"
        page_url = yield(curr_page+1)
        page_element = "<a class='pagelink' href='#{page_url}'>#{label}</a>"
      else
        page_url = yield(label)
        if label.to_i == curr_page
          page_element = "<span class='pagelink'>#{label}</span>"
        else
          page_element = "<a class='pagelink' href='#{page_url}'>#{label}</a>"
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