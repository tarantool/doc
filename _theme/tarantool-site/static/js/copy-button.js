function copyButtonOnClick() {
    var $this = $(this);
    $this.text('COPIED').addClass('copied');
    setTimeout(() => {
        $this.text('').removeClass('copied')
    }, 1000);
}

function transformTarantoolSession(container) {
    container.find('.p-Indicator').nextUntil('.nn').remove();
    container.find('.go, .gp, .gt, .nn, .c1, .no, .p-Indicator').remove();
    container.find('.gt').nextUntil('.gp, .go').remove();
}

function transformConsole(container) {
    container.find('.go, .gp, .c1').remove();
}

function transformOther(container) {
    container.find('.go, .gp').remove();
}

function getCopyText(pre) {
    var isTarantoolSession = pre.parents('.highlight-tarantoolsession').length > 0;
    var isConsole = !isTarantoolSession && (pre.parents('.highlight-console').length > 0 || pre.parents('.highlight-bash').length > 0);

    var container = pre.clone();

    switch (true) {
        case isTarantoolSession:
            transformTarantoolSession(container);
            break;
        case isConsole:
            transformConsole(container);
            break;
        default:
            transformOther(container);
            break;
    }

    container.find('span:empty').parent().remove();

    var html = container.html();
    html = html
        .split('\n')
        .map(function(v) {
            // Crutch. Deletes indent before && symbols in one of code-blocks
            if (/^\s*<span/.test(v) && />&amp;&amp;/.test(v)) return v.trim();
            if (/^\s*<span/.test(v)) return v;
            
            return v.trim();
        })
        .filter((v) => v !== '')
        .join('\n');

    container.html(html);

    return container.text().trim();
}

function initCopyButtons() {
    var div = $('.highlight:not(.js-copy-button)');
    if (div.length === 0) {
        return;
    }

    div.each(function() {
        var $this = $(this);
        $this.addClass('js-copy-button');

        var pre = $this.find('pre');
        if (pre.length !== 1) {
            return;
        }

        pre.addClass('full');

        var text = getCopyText(pre);
        if (!text) {
            return;
        }

        // add button
        var button = $('<span class="copybutton" role="button" data-component="copy-button"></span>');
        button.attr('title', 'Hide the prompts and output');
        button.data('hidden', 'false');
        button.data('copy-text', text);
        button.click(copyButtonOnClick);

        $this.prepend(button);
    });
}

$(function () {
    initCopyButtons();

    new ClipboardJS('.copybutton', {
        text: (trigger) => $(trigger).data('copy-text')
    });
});
