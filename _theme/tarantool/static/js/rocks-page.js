$(function() {
  var button = $('.b-download-header-menu-button');
  var rocks_menu = $('#rocks-menu');
  var rocks_header = $('#rocks-general-header');
  var rocks_body = $('#rocks-body');
  var rocks_content = $('.p-rocks-content');

  var isOpened = true;

  if (button && rocks_menu) {
    button.click(function(event) {
      if (isOpened) rocks_menu.hide();
      else rocks_menu.show();

      isOpened = !isOpened;
    });
  }

  if (rocks_menu) {
    placeMenu();
    $(window).resize(function() {
      placeMenu();
    });
  }

  function placeMenu() {
    if ($(window).width() >= 768) {
      rocks_body.prepend(rocks_menu);
      rocks_menu.show();
      isOpened = true;
    }
    else {
      rocks_header.after(rocks_menu);
    }
  }

  if ($(window).width() >= 768) {
    rocks_content.css("max-height", rocks_menu.find('ul').height());
  }
});
