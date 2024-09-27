$(function() {
  var menu_button = $('.doc-page-header__menu-button');
  var b_cols_content_left = $('#b-cols_content_left');
  var b_cols_content = $('#b-cols_content');
  var doc_page_header = $('#doc-page-header');
  var sidebar_close = $('#sidebar_close');

  var isOpen = false;

  menu_button.click(function() {
    if (b_cols_content_left) {
      if (isOpen) {
          b_cols_content_left.hide();
          document.body.style.overflow = "auto";
      } else {
          b_cols_content_left.show();
          document.body.style.overflow = "hidden";
      }

      isOpen = !isOpen;
    }
  });

  sidebar_close.click(function() {
    if (b_cols_content_left) {
      if (isOpen) {
          b_cols_content_left.hide();
          document.body.style.overflow = "auto";
      } 
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
    if ($(window).width() > 1024) {
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
});
