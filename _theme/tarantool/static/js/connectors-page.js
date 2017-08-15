$(function() {
  // var p_connectors = $('.p-connectors');
  var p_connectors_menu = $('.p-connectors-page-menu');
  var p_connectors_content = $('.p-connectors-page-content');

  if ($(window).width() >= 568) {
    p_connectors_content.css("max-height", p_connectors_menu.find('ul').height());
  }
});
