$(function() {
    $("ul.b-menu a").each(function() {
        if (
            ($(this).attr('href') === window.location.pathname                                               ) ||
            ($(this).attr('href').indexOf("/doc/") === 0     && window.location.pathname.indexOf("/doc/") === 0    ) ||
            ($(this).attr('href').indexOf("/en/download") === 0 && window.location.pathname.indexOf("/en/download") === 0)
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
