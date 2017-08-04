$(function() {
  var button = $('.b-download-header-menu-button');
  var rocks_menu = $('#rocks-menu');
  var rocks_header = $('#rocks-general-header');
  var rocks_body = $('#rocks-body');

  console.log('ROCKS MENU SCRIPT', rocks_menu, rocks_body);

  var isOpened = true;

  if (button && rocks_menu) {
    button.click(function(event) {
      if (isOpened) rocks_menu.hide();
      else rocks_menu.show();

      isOpened = !isOpened;
    });

    // os_installation_menu.find('li').each(function(i, elem) {
    //   if ($(elem).find('a').attr('href') === '#') $(elem).addClass('active');
    // });
  }

  if (rocks_menu) {
    placeMenu();
    $(window).resize(function() {
      placeMenu();
    });
  }

  function placeMenu() {
    if ($(window).width() >= 768) rocks_body.prepend(rocks_menu);
    else rocks_header.after(rocks_menu);
  }
});
