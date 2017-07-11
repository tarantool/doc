// https://docs.python.org/3/_static/copybutton.js
$(document).ready(function() {
    /* Add a [>>>] button on the top-right corner of code samples to hide
     * the >>> and ... prompts and the output and thus make the code
     * copyable. */
    var div = $('.highlight');
    var pre = div.find('pre');

    // get the styles from the current theme
    pre.parent().parent().css('position', 'relative');
    var hide_text = 'Hide the prompts and output';
    var show_text = 'Show the prompts and output';
    var border_width = pre.css('border-top-width');
    var border_style = pre.css('border-top-style');
    var border_color = pre.css('border-top-color');
    var button_styles = {
        'cursor':'pointer', 'position': 'absolute', 'top': '0', 'right': '0',
        'border-color': border_color, 'border-style': border_style,
        'border-width': border_width, 'color': border_color, 'text-size': '75%',
        'font-family': 'monospace', 'padding-left': '0.2em', 'padding-right': '0.2em',
        'border-radius': '0 3px 0 0'
    }

    // create and add the button to all the code blocks that contain >>>
    div.each(function(index) {
        var jthis = $(this);
        if (jthis.find('.gp').length > 0) {
            // add copy-pasteable version
            jthis.find("pre").addClass('full');
            var shortVersion = jthis.find("pre").clone();
            shortVersion.find('.p-Indicator').nextUntil('.nn').remove();
            shortVersion.find('.go, .gp, .gt, .nn, .c1, .no, .p-Indicator').remove();
            shortVersion.find('.gt').nextUntil('.gp, .go').remove();
            shortVersion.removeClass("full");
            shortVersion.addClass("short");
            shortVersion.hide();

            shortVersion.find('span').each(function(i, v) {
                if ($(v).text() === '') $(v).remove();
            });

            var html = shortVersion.html();
            html = html.split('\n').map(function(v) {
                if (/^\s*<span/.test(v)) return v;
                else return v.trim();
            }).filter(function(v) {
                return v != '';
            }).join('\n');
            shortVersion.html(html);
            jthis.prepend(shortVersion);

            //add button
            var button = $('<span class="copybutton">&gt;&gt;&gt;</span>');
            button.css(button_styles)
            button.attr('title', hide_text);
            button.data('hidden', 'false');
            jthis.prepend(button);
        }
        // tracebacks (.gt) contain bare text elements that need to be
        // wrapped in a span to work with .nextUntil() (see later)
        jthis.find('pre:has(.gt)').contents().filter(function() {
            return ((this.nodeType == 3) && (this.data.trim().length > 0));
        }).wrap('<span>');
    });

    // define the behavior of the button when it's clicked
    $('.copybutton').click(function(e){
        e.preventDefault();
        var button = $(this);
        if (button.data('hidden') === 'false') {
            // hide the code output
            button.parent().find('.full').hide();
            button.parent().find('.short').show();
            button.css('text-decoration', 'line-through');
            button.attr('title', show_text);
            button.data('hidden', 'true');
        } else {
            // show the code output
            button.parent().find('.full').show();
            button.parent().find('.short').hide();
            button.css('text-decoration', 'none');
            button.attr('title', hide_text);
            button.data('hidden', 'false');
        }
    });
});
