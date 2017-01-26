$(function() {
  $("ul.b-menu a").each(function() {
    if (($(this).attr('href') === window.location.pathname) ||
        ($(this).attr('href').startsWith("/doc/") &&
         window.location.pathname.startsWith("/doc/")) ||
        ($(this).attr('href').startsWith("/download") &&
         window.location.pathname.startsWith("/download"))) {
      $(this).addClass("p-active");
    }
  });
});

$(function() {
    $(".b-search-btn").click(function() {
        $(".b-header_menu-bottom").toggleClass('p-active');
        $(".b-header_menu-bottom input").focus();

        $(this).toggleClass('p-active');
    })
});
