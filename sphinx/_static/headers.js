$(document).ready(function () {

  /* Remove first headers, since we move them into Black stripe */
  $("div>h1").remove();

  /* Add anchor before every function name. Also, add divs for good wrapping */
  $(''.concat(
    "[id^='lua-object'], [id^='lua-function'], [id^='lua-data'],  ",
    "[id^='lua-объект'], [id^='lua-функция'],  [id^='lua-данные'],",
    "[id^='c.'], [id^='_CPP'], h2, h3, h4, h5, h6                 "
  )).each(
    function(i, el) {
      var icon = '<i class="fa fa-link"></i>';
      var hll = '<div class="b-doc-hlink_left"></div>';
      var hlr = '<div class="b-doc-hlink_right"></div>'
      var hlp = '<div class="b-doc-hlink></div>">'
      var hlink = $(el).find(".headerlink");
      var hlink_id = hlink.attr("href");
      if (typeof(hlink_id) != 'undefined') {
        $(hlink).remove();
        var lpane = $("<a />").addClass("headerlink").attr("href", hlink_id);
        lpane = lpane.html(icon).wrap(hll).parent();
        var rpane = $(el).clone().wrapInner(hlr);
        var pane = rpane.prepend(lpane).wrapInner(hlp);
        $(el).replaceWith(pane);
      }
    }
  );

  /* Add icon to NOTES */
  $(".admonition.note p.first.admonition-title").each(
    function(i, el) {
      var icon = '<i class="fa fa-comments-o"></i>';
      $(el).html(icon + $(el).html());
    }
  );

  /* Add icon to WARNINGS */
  $(".admonition.warning p.first.admonition-title").each(
    function(i, el) {
      var icon = '<i class="fa fa-exclamation-triangle"></i>';
      $(el).html(icon + $(el).html());
    }
  );

  /* Pin left menu - bad design, need to redo */
  $(".b-cols_content_left").pin({containerSelector: ".b-cols_content"});

  /* Move all rparams from table */
  $("table.docutils.field-list").each(
      function(i, table) {
        $(table).find("tr").each(function(i, el) {
          /* name of parameter */
          var left = $(el).children("th.field-name");
          if (left.html() == "Rtype:") {
            left.html("Return type:");
          }
          left = $("<div />").addClass("b-doc-param_left").html(
            $("<p />").html(left.html())
          );
          /* body of parameter */
          var right = $(el).children("td.field-body");
          right = $("<div />").addClass("b-doc-param_right").html(right.html());
          /* result of (l + r) */
          var pane = $("<div />").addClass("b-doc-param").append([left, right]);
          // return pane
          $(table).before(pane);
        })
        $(table).empty().remove();
      }
  );
});

// vim: syntax=javascript ts=2 sts=2 sw=2 expandtab
