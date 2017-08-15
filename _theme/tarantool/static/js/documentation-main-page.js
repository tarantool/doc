$(function() {
    var doc_main_page_header_path = '.documentation-main-page-header-path';
    var version_switcher = '.version-switcher';
    var content = $('.documentation-main-page-content');
    var single_page_toctree = $('.single-page-toctree');

    // Adding available versions list to doc main page
    if ($(doc_main_page_header_path)) {
      if ($(version_switcher)) {
        $(doc_main_page_header_path).after($(version_switcher));
      }
    }

    // Swaping list items in menu
    var main_ul = $($(content.children('.toctree-wrapper')).children('ul'));
    var sorted_main_ul = main_ul;
    $(sorted_main_ul.children('li')[1]).insertAfter($(sorted_main_ul.children('li')[2]));
    main_ul = sorted_main_ul;

    // Swaping list items in single page menu
    // var single_page_ul = $(single_page_toctree.children('ul'));
    // var sorted_single_page_ul = single_page_ul;
    // $(sorted_single_page_ul.children('li')[1]).insertAfter($(sorted_single_page_ul.children('li')[2]));
    // single_page_ul = sorted_single_page_ul;
});
