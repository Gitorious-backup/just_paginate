
DESCRIPTION:
===========

just_paginate is a framework-agnostic approach to creating paginated
webpages. It has no external dependencies and works with any web
framework.

Consists of two main methods, paginate and page_navigation. 

JustPaginate.paginate helps you slice up your collections and, given a
page number, entities per page and totoal entity count, gives you the
correct range of indexes you need to get. You supply a block where you
specify how elements with those indices are to be gathered. Your block
needs to return those elements. The JustPaginate method then returns
the objects that you sliced in your block, as well as the total number
of pages in the pagination.

JustPaginate.page_navigation generates html for a page-navigator
widget that will let you navigate arbitrarily large page ranges: if
the range is larger than what can be displayed, it truncates the range
of pages. You supply it with current page number, and total number of
pages. You pass in a block which, given the page number, will let you
construct a html link to that page number.

Note: There is also a JustPaginate.page_value helper method that will
take an arbitrary object, and try to translate it to a (default) page
number. If you are using Rails you can simply pass the param
specifying current page and JustPaginate will do its best to translate
it to a page number integer.


EXAMPLES:
======

Say we have a Rails app, with an index page of paginated Projects. You
could do this in the controller, to select the 20 projects for the
current page:

```ruby
@page = JustPaginate.page_value(params[:page])
@project_count = Project.count
@projects, @total_pages = JustPaginate.paginate(@page, 20, @project_count) do |index_range|
  Project.all.slice(index_range)
end
```

And in the index.html.erb file, to generate the page navigation:

```ruby
<%= JustPaginate.page_navigation(@page, @total_pages) { |page_no| "/projects/?page=#{page_no}" } -%>
```

INSTALL:
========

`sudo gem install just_paginate` 

Or simply stick just_paginate into your Gemfile and use Bundler to
pull it down.


LICENSE:
========

just_paginate is free software licensed under the
[GNU Affero General Public License (AGPL)](http://www.gnu.org/licenses/agpl-3.0.html). just_paginate
is developed as part of the Gitorious project.
