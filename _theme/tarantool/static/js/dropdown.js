$(function() {
  var open = 'dropdown-open';
  var close = 'dropdown-close';
  var download_drop_item = '.dropdown-list-item-url';
  var download_drop_item_parent = '.dropdown-list-item';
  var download_drop_box = '.dropdown-list-item-content';
  if ($(download_drop_item)) {
    var download_drop_items = $(download_drop_item);
    for (var i=0; i<download_drop_items.length; i++) {
      if ($(download_drop_items[i]).parents(download_drop_item_parent).find(download_drop_box).length != 0) {
        $(download_drop_items[i]).addClass(close);
      }
    };
  }
  $(download_drop_item).click(function() {
    if($(this).parents(download_drop_item_parent).find(download_drop_box).length!=0) {
      if ($(this).hasClass(open)) {
        $(this).removeClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(close);
      } else {
        $(this).addClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(close);
      }
    }
    return false;
  });
});
