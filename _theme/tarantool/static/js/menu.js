$(function() {
    $("ul.b-menu a").each(function() {
        if (
            ($(this).attr('href') === window.location.pathname                                               ) ||
            ($(this).attr('href').startsWith("/doc/")     && window.location.pathname.startsWith("/doc/")    ) ||
            ($(this).attr('href').startsWith("/en/download") && window.location.pathname.startsWith("/en/download"))
           ) {
            $(this).addClass("p-active");
        }
    });
});


$(function() {
    $(".b-search-btn").click(function() {
        var bottom_menu = $(".b-header_menu-bottom");
        bottom_menu.toggleClass('p-active');

        if (bottom_menu.hasClass('p-active')) {
            $(".b-header_menu-bottom .b-header_menu-search-text").focus();
        }
    })
})
