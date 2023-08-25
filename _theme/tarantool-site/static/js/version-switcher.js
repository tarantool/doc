
function initVersionSwitcher() {
    var $versionSwitcher = $('[data-component="version-switcher"]');
    var $versionSwitcherDrop = $versionSwitcher.find('[data-placeholder="version-switcher-drop"]');
    var $versionSwitcherTrigger = $versionSwitcher.find('[data-placeholder="version-switcher-trigger"]');
    var timeout;

    $versionSwitcherTrigger.on('click', function(event) {
        clearTimeout(timeout);
        event.preventDefault();
        if ($versionSwitcher.attr('data-active') === '1') {
            $versionSwitcher.attr('data-active', '0');
        } else {
            $versionSwitcher.attr('data-active', '1');
            $versionSwitcherDrop.focus();
        }
    });
    
    $versionSwitcherDrop.on('focusout', function() {
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            $versionSwitcher.attr('data-active', '0')
        }, 200);
    });
}

$(function() {
   initVersionSwitcher();
});
