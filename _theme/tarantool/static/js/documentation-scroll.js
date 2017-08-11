$(function() {

  console.log('SCROLL SCRIPT');

  var b_cols_content = $('#b-cols_content');
  var b_cols_content_left = $('#b-cols_content_left');
  var b_cols_content_right = $('#b-cols_content_right');

  b_cols_content_left.bind("mousewheel",function(ev, delta) {
    console.log('SCROLL');
    var scrollTop = $(this).scrollTop();
    $(this).scrollTop(scrollTop-Math.round(delta * 20));
  });

  // b_cols_content_left.bind("mousewheel",function(ev, delta) {
  //   var scrollTop = $(this).scrollTop();
  //   $(this).scrollTop(scrollTop-Math.round(delta * 20));
  // });
});
