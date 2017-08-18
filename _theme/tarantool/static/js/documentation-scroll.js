$(function() {
  var b_cols_content = $('#b-cols_content');
  var b_cols_content_left = $('#b-cols_content_left');
  var b_cols_content_right = $('.b-cols_content_right');

  height = Math.max($(window).height() - 44, b_cols_content_right.outerHeight(true));
  b_cols_content_left.css({
    "height": height,
    "overflow-y": "scroll"
  });
});
