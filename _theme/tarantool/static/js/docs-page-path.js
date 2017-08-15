$(function() {
  var doc_page_header = $("#doc-page-header");
  var path = $(doc_page_header.find(".path"));

  if ($(window).width() > 1350) return;

  var count = 0;
  var MAX = 67;

  path.find('.path-item').each(function(i, el) {
    count += $.trim($(el).text()).length;
  });

  if (count > MAX) {
    var toTrimCount = Math.ceil((count - MAX) / path.find('.path-item').length);

    path.find('.path-item').each(function(i, el) {
      var text = $.trim($(el).text());
      text = text.substring(0, text.length - toTrimCount - 3) + '...';
      $(el).text(text);
    });
  }
});
