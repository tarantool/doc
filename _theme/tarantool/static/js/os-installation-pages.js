$(function() {
  var button = $('.b-download-header-menu-button');
  var os_installation_menu = $('.b-os-installation-menu');

  var isOpened = true;

  button.click(function(event) {
    if (isOpened) os_installation_menu.hide();
    else os_installation_menu.show();

    isOpened = !isOpened;
  });

  os_installation_menu.find('li').each(function(i, elem) {
    if ($(elem).find('a').attr('href') === '#') $(elem).addClass('active');
  });

  $(window).resize(function() {
    if ($(window).width() >= 768) {
      os_installation_menu.show();
      isOpened = true;
    }
  });
});
