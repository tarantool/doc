$(function() {
  // var p_connectors = $('.p-connectors');
  var p_connectors_menu = $('.p-connectors-page-menu');
  var p_connectors_alphabetical_menu = $('.p-connectors-page-alphabetical-menu');
  var p_connectors_content = $('.p-connectors-page-content');

  if ($(window).width() >= 568) {
    p_connectors_content.css("height", p_connectors_menu.find('ul').height());
  }
  else {
    p_connectors_content.css("height", p_connectors_alphabetical_menu.find('ul').height());
  }
});
