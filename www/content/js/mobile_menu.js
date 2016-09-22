$(function() {
    var toggle_navigation = '.toggle-navigation';
    var burger_button     = '.b-burger-button';
    var menu_mobile       = '.b-menu_mobile';
    var doc_menu          = '.b-menu-toc';

    $(burger_button).on('click', function(event) {
        // console.log("burger click");
        event.stopPropagation();
        $(menu_mobile).toggleClass('active');
        $(doc_menu   ).removeClass('active');
        $(toggle_navigation).removeClass('active');
        if ($(menu_mobile).hasClass('active')) {
            console.log("adding stop-scroll")
            $("body").addClass('stop-scroll');
        } else {
            console.log("removing stop-scroll")
            $("body").removeClass('stop-scroll');
        }
    });

    $(toggle_navigation).on('click', function(event) {
        event.stopPropagation();
        if (!$(this).hasClass('active')) {
            // console.log("navigation click - on");
            $(this).addClass('active');
            $(doc_menu).addClass('active');
            $("body").addClass('stop-scroll');
        } else {
            // console.log("navigation click - off");
            $(this).removeClass('active');
            $(doc_menu).removeClass('active');
            $("body").removeClass('stop-scroll');
        }
    });

    $("body").click(function() {
        // console.log("body click");
        $(doc_menu).removeClass("active");
        $(toggle_navigation).removeClass("active");
        $(menu_mobile).removeClass("active");
        $("body").removeClass('stop-scroll');
    });
});
