$(function() {
    // FIXME Delete comments
    
    // var doc_main_page_title = '.documentation-main-page-title';
    // var b_block_wrapper = '.b-block-wrapper';
    // var b_section_title = '.b-section-title';
    // var nav_button = "#start-menu-nav-button";
    // var start_menu = '.start-menu';
    var doc_main_page_header_path = '.documentation-main-page-header-path';
    var version_switcher = '.version-switcher';

    // Adding available versions list to doc main page
    if ($(doc_main_page_header_path)) {
      if ($(version_switcher)) {
        $(doc_main_page_header_path).after($(version_switcher));
      }
    }

    // if ($(doc_main_page_title)) {
    //   $(doc_main_page_title).find(b_section_title).addClass('toggle-navigation');
    //   $(doc_main_page_title).find(b_section_title).attr('id', 'start-menu-nav-button');
    // }

    // $(nav_button).on('click', function(event) {
    //     event.stopPropagation();
    //     if (!$(this).hasClass('active')) {
    //         $(this).addClass('active');
    //         $(start_menu).addClass('active');
    //         $("body").addClass('stop-scroll');
    //     } else {
    //         $(this).removeClass('active');
    //         $(start_menu).removeClass('active');
    //         $("body").removeClass('stop-scroll');
    //     }
    // });

    // $("body").click(function() {
    //     $(start_menu).removeClass("active");
    //     $(nav_button).removeClass("active");
    //     $("body").removeClass('stop-scroll');
    // });
});
