..  code-block:: lua

    for page in paged_iter("X", 10) do
      print("New Page. Number Of Tuples = " .. #page)
      for i=1,#page,1 do print(page[i]) end
    end