$(function() {
  // var drop_item = '.b-path-list-item-icon';
  // var drop_item_parent = '.version-switcher';
  // var drop_list = '.b-path-list-drop';
  // var open  = 'p-drop-open';
  // var close = 'p-drop-close';
  // var download_drop_item = '.b-download-list-item-url';
  // var download_drop_item_parent = '.b-download-list-item';
  // var download_drop_box = '.b-download-list-item-drop';

  var version_switcher = $('.version-switcher');
  var version_switcher_current = $(version_switcher.find('.version-switcher-current'));
  var version_switcher_item_icon = $(version_switcher_current.find('.version-switcher-item-icon'));
  var version_switcher_drop = $(version_switcher.find('.version-switcher-drop'));

  var open = 'fa-caret-up';
  var close = 'fa-caret-down';

  console.log('BEGIN', version_switcher, version_switcher_current, version_switcher_drop);
  console.log('BEGIN', version_switcher_item_icon);

  if (version_switcher_drop) {
    version_switcher_drop.hide();
  }

  version_switcher_current.click(function(e) {
    e.preventDefault();

    console.log('CLICK');

    if (version_switcher_item_icon.hasClass(close)) {
      console.log('HAS CLASS CLOSE');
      openSwitcher();
    }
    else {
      console.log('HAS NOT CLASS CLOSE');
      closeSwitcher();
    }
  });

  version_switcher.mouseleave(function() {
    console.log('MOUSE LEAVE');
    closeSwitcher();
  });

  function closeSwitcher() {
    console.log('CLOSE CALLED');
    version_switcher_drop.fadeOut(200);
    version_switcher_item_icon.removeClass(open);
    version_switcher_item_icon.addClass(close);
  }

  function openSwitcher() {
    console.log('OPEN CALLED');
    version_switcher_drop.fadeIn(200);
    version_switcher_item_icon.removeClass(close);
    version_switcher_item_icon.addClass(open);
  }

  // if ($(drop_item)) {
  //   var drop_items = $(drop_item);
  //   for (var i = 0; i<drop_items.length; i++) {
  //     if($(drop_items[i]).parents(drop_item_parent).find(drop_list).length!=0) {
  //       $(drop_items[i]).addClass(close);
  //     }
  //   };
  // }
  // $(drop_item).click(function() {
  //   if($(this).parents(drop_item_parent).find(drop_list).length != 0) {
  //     if ($(this).hasClass(close)) {
  //       $(this).parents(drop_item_parent).find(drop_list).fadeIn(100);
  //     } else {
  //       $(this).parents(drop_item_parent).find(drop_list).fadeOut(100);
  //     }
  //     $(this).toggleClass(close).toggleClass(open);
  //     return false;
  //   }
  // });
  // $(drop_item_parent).mouseleave(function() {
  //   if ($(this).find(drop_list).length != 0) {
  //     if ($(this).find(drop_item).hasClass(open)) {
  //       $(this).find(drop_item).toggleClass(close).toggleClass(open);
  //       $(this).find(drop_list).fadeOut(100);
  //     }
  //   }
  //   return false;
  // });
  // if ($(download_drop_item)) {
  //   var download_drop_items = $(download_drop_item);
  //   for (var i = 0; i< download_drop_items.length; i++) {
  //     if($(download_drop_items[i]).parents(download_drop_item_parent).find(download_drop_box).length != 0) {
  //       $(download_drop_items[i]).addClass(close);
  //     }
  //   };
  // }
  // $(download_drop_item).click(function() {
  //   if($(this).parents(download_drop_item_parent).find(download_drop_box).length != 0) {
  //     if ($(this).hasClass(open)) {
  //       $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(open);
  //     } else {
  //       $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(open);
  //     }
  //     $(this).toggleClass(open)
  //   }
  //   return false;
  // });
});
