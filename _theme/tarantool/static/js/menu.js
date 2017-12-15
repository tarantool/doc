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

$(function() {
    window.onload = function() {
        if (window.location.pathname.match(/\/doc/g)) {
            var float_block = document.getElementById("b-cols_content_left"),
                scroll = window.pageYOffset || document.documentElement.scrollTop,
                scrollHeight = Math.max(
                    document.body.scrollHeight, document.documentElement.scrollHeight,
                    document.body.offsetHeight, document.documentElement.offsetHeight,
                    document.body.clientHeight, document.documentElement.clientHeight
                ), top = float_block.offsetTop, bottom = 0;

                if (scroll + document.documentElement.clientHeight >= scrollHeight - 50) {
                    top = scrollHeight - (scroll + document.documentElement.clientHeight) - 50;
                    bottom = Math.abs(top);

                    float_block.style.top = 44 + top + "px";
                    float_block.style.bottom = bottom + "px";
                } else {
                    float_block.style.top = "44px";
                    float_block.style.bottom = "0px";
                }

            window.onresize = function() {
                if (window.innerWidth <= 1024) {
                    float_block.style.top = "44px";
                    float_block.style.bottom = "0px";
                    return true
                }
                scrollHeight = Math.max(
                    document.body.scrollHeight, document.documentElement.scrollHeight,
                    document.body.offsetHeight, document.documentElement.offsetHeight,
                    document.body.clientHeight, document.documentElement.clientHeight
                );
                scroll = window.pageYOffset || document.documentElement.scrollTop;
                
                if (scroll + document.documentElement.clientHeight >= scrollHeight - 50) {
                    top = scrollHeight - (scroll + document.documentElement.clientHeight) - 50;
                    bottom = Math.abs(top);

                    float_block.style.top = 44 + top + "px";
                    float_block.style.bottom = bottom + "px";
                } else {
                    float_block.style.top = "44px";
                    float_block.style.bottom = "0px";
                }
            };

            window.onscroll = function() {
                if (window.innerWidth <= 1024) return true;
                scroll = window.pageYOffset || document.documentElement.scrollTop;

                if (scroll + document.documentElement.clientHeight >= scrollHeight - 50) {
                    top = scrollHeight - (scroll + document.documentElement.clientHeight) - 50;
                    bottom = Math.abs(top);

                    float_block.style.top = 44 + top + "px";
                    float_block.style.bottom = bottom + "px";
                } else {
                    float_block.style.top = "44px";
                    float_block.style.bottom = "0px";
                }
            }
        }
    }
})