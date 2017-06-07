$(function() {
    var doc_main_page_title = '.documentation-main-page-title';
    var b_block_wrapper = '.b-block-wrapper';
    var b_section_title = '.b-section-title';
    var toggle_navigation = '.toggle-navigation';
    var b_page_header = '.b-page_header';
    var doc_main_page_content = '.documentation-main-page-content';
    var start_menu = '.start-menu';

    if ($(doc_main_page_title)) {
      $(doc_main_page_title).find(b_section_title).addClass('toggle-navigation');
    }

    $(toggle_navigation).on('click', function(event) {
        event.stopPropagation();
        if (!$(this).hasClass('active')) {
            $(this).addClass('active');
            $(start_menu).addClass('active');
            $("body").addClass('stop-scroll');
        } else {
            $(this).removeClass('active');
            $(start_menu).removeClass('active');
            $("body").removeClass('stop-scroll');
        }
    });

    $("body").click(function() {
        $(start_menu).removeClass("active");
        $(toggle_navigation).removeClass("active");
        $("body").removeClass('stop-scroll');
    });

    // Adding available versions list to doc main page
    if ($(doc_main_page_content)) {
      if ($(b_page_header)) {
        $(doc_main_page_content).prepend($(b_page_header));
      }
    }
});
