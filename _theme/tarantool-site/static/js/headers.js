$(function() {
  /* Fix for singlehtml and bad links path */
  if ($('[class$="singlehtml"]').length) {
    $("a[href]").each(function(i, el) {
        $(el).attr("href", $(el).attr("href").replace(/^doc\/[\d.]+\/singlehtml\.html/, ''));
    })
  }

});

$(function () {
  /* Add anchor before every function name. Also, add divs for good wrapping */
  $(''.concat(
    "dl.function>dt, dl.data>dt, dl.class>dt, dl.varfunc>dt, dl.method>dt, ",
    "dl.type>dt, dl.enum>dt, dl.enumerator>dt, dl.macro>dt, dl.operator>dt"
  )).each(function(i, el) {
      var icon = '<i class="fa fa-link"></i>';
      var hll = '<div class="b-doc-flink_left"></div>';
      var hlr = '<div class="b-doc-flink_right"></div>'
      var hlp = '<div class="b-doc-flink"></div>'
      var hlink = $(el).find(".headerlink");
      var hlink_id = hlink.attr("href");
      $(hlink).remove();
      var lpane = $("");
      if (typeof(hlink_id) != 'undefined') {
        lpane = $("<a />").addClass("headerlink").attr("href", hlink_id);
        lpane = lpane.html(icon).wrap(hll).parent();
      } else {
        lpane = $(hll);
      }
      var rpane = $(el).clone().wrapInner(hlr);
      var pane = rpane.prepend(lpane).wrapInner(hlp);
      $(el).replaceWith(pane);
  })

  /* Base admonition function */
  function admonition_icon(name) {
    return function(i, el) {
      var icon = $('<i class="fa"></i>').addClass(name);
      $(el).prepend(icon);
    }
  }

  /* Add icon to NOTES, WARNINGS, FACTS */
  $(".admonition.note    p.first.admonition-title").each(admonition_icon("fa-comments-o"          ));
  $(".admonition.warning p.first.admonition-title").each(admonition_icon("fa-exclamation-triangle"));
  $(".admonition.fact    p.first.admonition-title").each(admonition_icon("fa-hand-o-up"           ));


  /* Move all rparams from table */
  $("table.docutils.field-list").each(
    function(i, table) {
      $(table).find("tr").each(function(i, el) {
        // name of parameter
        var left = $(el).children("th.field-name");
        var leftHtmlLowerCase = left.html().toLowerCase();
        if (leftHtmlLowerCase == "rtype:") {
            left.html("Return type:");
        } else if (
            leftHtmlLowerCase != 'parameters:' && leftHtmlLowerCase != 'параметры:' &&
            leftHtmlLowerCase != 'return:' && leftHtmlLowerCase != 'возвращает:'
        ) {
            return;
        }

        left = $("<div />").addClass("b-doc-param_left").html(
          $("<p />").html(left.html())
        );
        // body of parameter
        var right = $(el).children("td.field-body");
        right = $("<div />").addClass("b-doc-param_right").html(right.html());
        // result of (l + r)
        var pane = $("<div />").addClass("b-doc-param").append([left, right]);
        // return pane
        $(table).before(pane);
        $(el).remove();
      })
      if ($(table).find("tr").length == 0) {
        $(table).remove();
      }
    }
  );

  /* Search additions for sphinx */
  $(function() {
    $(".b-header-search input").focusin(function() {
      $(this).attr("placeholder", "Search tarantool.org web site and documentation");
    });
    $(".b-header-search input").focusout(function() {
      $(this).attr("placeholder", "");
    });
    $(".b-doc-search .b-header-search input").focus();
  });

  /* Recursive sliding menu with plus/minus icons for toggling */
  /* Delete numbers in the chapter */
  function toggle_recursive() {

    var menu = $(this)
    if (menu.is('li')) {
      var ul = menu.children("ul");
      var has_ul = (ul.length > 0);
      if (ul.length > 0) {
        var link = menu.children("a");
        link.css({
          "position": "relative",
        }).before(
          $('<i class="fa fa-caret-down"></i>')
        );
        link.siblings("i").click(function(event) {
          // if (is_mobile) event.stopPropagation();

          menu.children("ul").slideToggle(10);
          $(this).toggleClass("fa-caret-down").toggleClass("fa-caret-up");
        });
        ul.children("li").each(toggle_recursive);
        menu.children("ul").css('display', 'none');
      }
    }
  }

  /* Some hacks for sliding TOC and pinned left menu */
  $(function() {
    $(".b-cols_content_left").each(function() {
      /* delete numbers from left toc */
      $(this).find("li.toctree-l1").each(toggle_recursive).find("a").each(function() {
        var before = $(this).text();
        var after = before.replace(/^[\d.]* (.*)/, '$1');
        $(this).text(after)
      })

      $(this).find("a.current").each(function() {
        $(this).siblings("i").click();
        $(this).parents("ul.current").prev().siblings("i").click();
      });

      $(this).find("a").click(function() {
        $(".b-menu-toc").removeClass('active');
        $(".toggle-navigation").removeClass('active');
      });

    });
  });
});
