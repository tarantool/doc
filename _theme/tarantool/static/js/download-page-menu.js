$(function() {
  var button = $('.b-download-header-menu-button');
  var menu = $('.b-os-installation-menu');

  var isOpened = false;

  button.click(function(event) {
    if (isOpened) menu.hide();
    else menu.show();

    isOpened = !isOpened;
  });

  menu.find('li').each(function(i, elem) {
    if ($(elem).find('a').attr('href') === '#') $(elem).addClass('active');
  });

  menu.find('li').click(function(event) {
    window.location.replace($(event.target).find('a').attr('href'));
  });
});
