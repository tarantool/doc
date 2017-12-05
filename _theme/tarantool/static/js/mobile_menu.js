$(function() {
    var menu_button = $('.doc-page-header__menu-button');
    var b_cols_content_left = $('#b-cols_content_left');
    var b_cols_content = $('#b-cols_content');
    var doc_page_header = $('#doc-page-header');

    var isOpen = false;

    menu_button.click(function() {
      if (b_cols_content_left) {
        if (isOpen) b_cols_content_left.hide();
        else b_cols_content_left.show();

        isOpen = !isOpen;
      }
    });

    if (b_cols_content_left) {
      replaceMenu();
      $(window).resize(function() {
        replaceMenu();
      });
    }

    var isScreenSmall = false;
    function replaceMenu() {
      if ($(window).width() >= 1024) {
        b_cols_content.prepend(b_cols_content_left);
        b_cols_content_left.show();
        isOpen = true;
        isScreenSmall = false;
      }
      else {
        if (!isScreenSmall) b_cols_content_left.hide();
        doc_page_header.after(b_cols_content_left);
        isScreenSmall = true;
        isOpen = false;
      }
    }

    //FIXME The code below is deprecated. Probably need to delete.

    var toggle_navigation = '.toggle-navigation';
    var burger_button     = '.b-burger-button';
    var menu_mobile       = '.b-menu_mobile';
    var doc_menu          = '.b-menu-toc';
    // var b_cols_content_left = '.b-cols_content_left';

    $(burger_button).on('click', function(event) {
        // console.log("burger click");
        event.stopPropagation();
        $(menu_mobile).toggleClass('active');
        $(doc_menu   ).removeClass('active');
        // $(b_cols_content_left).removeClass('active');
        $(toggle_navigation).removeClass('active');
        if ($(menu_mobile).hasClass('active')) {
            // console.log("adding stop-scroll")
            $("body").addClass('stop-scroll');
        } else {
            // console.log("removing stop-scroll")
            $("body").removeClass('stop-scroll');
        }
    });

    $(toggle_navigation).on('click', function(event) {
        event.stopPropagation();
        if (!$(this).hasClass('active')) {
            // console.log("navigation click - on");
            $(this).addClass('active');
            $(doc_menu).addClass('active');
            // $(b_cols_content_left).addClass('active');
            $("body").addClass('stop-scroll');
        } else {
            // console.log("navigation click - off");
            $(this).removeClass('active');
            $(doc_menu).removeClass('active');
            // $(b_cols_content_left).removeClass('active');
            $("body").removeClass('stop-scroll');
        }
    });

    $("body").click(function() {
        // console.log("body click");
        $(doc_menu).removeClass("active");
        // $(b_cols_content_left).removeClass("active");
        $(toggle_navigation).removeClass("active");
        $(menu_mobile).removeClass("active");
        $("body").removeClass('stop-scroll');
    });

    // if ($('thead').length) {
    //     $('thead').parents('table').cardtable();
    // }
    // $('.stacktable  table').stacktable();
    // $('.cardtable   table').cardtable();
    // $('.stackcolumn table').stackcolumns();
});
