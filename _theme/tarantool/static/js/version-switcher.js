$(function() {
  var version_switcher = $('.version-switcher');
  var version_switcher_current = $(version_switcher.find('.version-switcher-current'));
  var version_switcher_item_icon = $(version_switcher_current.find('.version-switcher-item-icon'));
  var version_switcher_drop = $(version_switcher.find('.version-switcher-drop'));

  var open = 'fa-caret-up';
  var close = 'fa-caret-down';

  if (version_switcher_drop) {
    version_switcher_drop.hide();
  }

  version_switcher_current.click(function(e) {
    e.preventDefault();

    if (version_switcher_item_icon.hasClass(close)) {
      openSwitcher();
    }
    else {
      closeSwitcher();
    }
  });

  version_switcher.mouseleave(function() {
    closeSwitcher();
  });

  function closeSwitcher() {
    version_switcher_drop.fadeOut(200);
    version_switcher_item_icon.removeClass(open);
    version_switcher_item_icon.addClass(close);
  }

  function openSwitcher() {
    version_switcher_drop.fadeIn(200);
    version_switcher_item_icon.removeClass(close);
    version_switcher_item_icon.addClass(open);
  }
});
