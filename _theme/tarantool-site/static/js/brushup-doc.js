

function brushUpDoc() {
    function headerTdgEnterprise() {
        $(''.concat(
            "dl.function>dt, dl.data>dt, dl.class>dt, dl.varfunc>dt, dl.method>dt, ",
            "dl.type>dt, dl.enum>dt, dl.enumerator>dt, dl.macro>dt, dl.operator>dt"
        )).each(function (i, el) {
            var icon = '<i class="fa fa-link"></i>';
            var hll = '<div class="b-doc-flink_left"></div>';
            var hlr = '<div class="b-doc-flink_right"></div>'
            var hlp = '<div class="b-doc-flink"></div>'
            var hlink = $(el).find(".headerlink");
            var hlink_id = hlink.attr("href");
            $(hlink).remove();
            var lpane = $("");
            if (typeof (hlink_id) != 'undefined') {
                lpane = $("<a />").addClass("headerlink").attr("href", hlink_id);
                lpane = lpane.html(icon).wrap(hll).parent();
            } else {
                lpane = $(hll);
            }
            var rpane = $(el).clone().wrapInner(hlr);
            var pane = rpane.prepend(lpane).wrapInner(hlp);
            $(el).replaceWith(pane);
        })

        /* Add anchor before every function name. Also, add divs for good wrapping */
        $('h2, h3, h4, h5, h6').each(
            function (i, el) {
                var icon = '<i class="fa fa-link"></i>';
                var hll = '<div class="b-doc-hlink_left"></div>';
                var hlr = '<div class="b-doc-hlink_right"></div>'
                var hlp = '<div class="b-doc-hlink"></div>'
                var hlink = $(el).find(".headerlink");
                var hlink_id = hlink.attr("href");
                if (typeof (hlink_id) != 'undefined') {
                    $(hlink).remove();
                    var lpane = $("<a />").addClass("headerlink").attr("href", hlink_id);
                    lpane = lpane.html(icon).wrap(hll).parent();
                    var rpane = $(el).clone().wrapInner(hlr);
                    var pane = rpane.prepend(lpane).wrapInner(hlp);
                    $(el).replaceWith(pane);
                }
            }
        );

    }

    function headerDoc() {

        var doc_page_header = $("#doc-page-header");
        var path = $(doc_page_header.find(".path"));

        if ($(window).width() > 1350) return;

        var count = 0;
        var MAX = 67;

        path.find('.path-item').each(function(i, el) {
            count += $.trim($(el).text()).length;
        });

        if (count > MAX) {
            var toTrimCount = Math.ceil((count - MAX) / path.find('.path-item').length);

            path.find('.path-item').each(function(i, el) {
              var text = $.trim($(el).text());
              text = text.substring(0, text.length - toTrimCount - 3) + '...';
              $(el).text(text);
            });
        }
    }

    function headerTdgEnterpriseDoc() {
        if (window.location.pathname.match(/\/tdg|enterprise_doc|team|help|dev/g)) {
            headerTdgEnterprise()
        }
    }

    headerTdgEnterpriseDoc()

    headerDoc()

    /* Base admonition function */
    function admonition_icon(name) {
        return function (i, el) {
            var icon = $('<i class="fa"></i>').addClass(name);
            $(el).prepend(icon);
        }
    }

    /* Add icon to NOTES, WARNINGS, FACTS */
    $(".admonition.note    p.first.admonition-title").each(admonition_icon("fa-comments-o"));
    $(".admonition.warning p.first.admonition-title").each(admonition_icon("fa-exclamation-triangle"));
    $(".admonition.fact    p.first.admonition-title").each(admonition_icon("fa-hand-o-up"));

    $(''.concat(
        "dl.function>dt, dl.data>dt, dl.class>dt, dl.varfunc>dt, dl.method>dt, ",
        "dl.type>dt, dl.enum>dt, dl.enumerator>dt, dl.macro>dt, dl.operator>dt"
    )).each(function (i, el) {
        var icon = '<i class="fa fa-link"></i>';
        var hll = '<div class="b-doc-flink_left"></div>';
        var hlr = '<div class="b-doc-flink_right"></div>'
        var hlp = '<div class="b-doc-flink"></div>'
        var hlink = $(el).find(".headerlink");
        var hlink_id = hlink.attr("href");
        $(hlink).remove();
        var lpane = $("");
        if (typeof (hlink_id) != 'undefined') {
            lpane = $("<a />").addClass("headerlink").attr("href", hlink_id);
            lpane = lpane.html(icon).wrap(hll).parent();
        } else {
            lpane = $(hll);
        }
        var rpane = $(el).clone().wrapInner(hlr);
        var pane = rpane.prepend(lpane).wrapInner(hlp);
        $(el).replaceWith(pane);
    })

    /* Move all rparams from table */
    $("table.docutils.field-list").each(
        function (i, table) {
            $(table).find("tr").each(function (i, el) {
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
}

$(function() {
    brushUpDoc();
})
