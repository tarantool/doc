$(function() {
  var button = $('.b-download-header-menu-button');
  var os_installation_menu = $('.b-os-installation-menu');
  var connectors_page_menu = $('.p-connectors-page-menu');

  var isOpened = false;

  button.click(function(event) {
    if (isOpened) os_installation_menu.hide();
    else os_installation_menu.show();

    isOpened = !isOpened;
  });

  os_installation_menu.find('li').each(function(i, elem) {
    if ($(elem).find('a').attr('href') === '#') $(elem).addClass('active');
  });

  os_installation_menu.find('li').click(function(event) {
    window.location.replace($(event.target).find('a').attr('href'));
  });

  connectors_page_menu.find('li').click(function(event) {
    window.location.replace($(event.target).find('a').attr('href'));
  });
});
