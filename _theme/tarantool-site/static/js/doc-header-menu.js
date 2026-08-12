var SCROLL_TOP_TO_HIDE = 120;
var SCROLL_THROTTLE_TIMEOUT = 300;

var $win = $(window);
var $html = $('html');

function setAttr(attr) {
    if (attr && attr !== $html.attr('data-hidden-header')) {
        $html.attr('data-hidden-header', attr);
        $win.trigger('tarantool.io-toggle-data-hidden-header');
    }
}

function handleScroll(top) {
    var navigationMenuIsActive = $html.attr('data-header-navigation-menu-is-active') === '1';
    var dropdownMenuIsActive = $html.attr('data-header-dropdown-menu-is-active') === '1';

    var attr = navigationMenuIsActive || dropdownMenuIsActive || top || $win.scrollTop() < SCROLL_TOP_TO_HIDE ? '0' : '1';
    setAttr(attr);
}

function handleWheel(event) {
    if (event.originalEvent.deltaY !== 0) {
        handleScroll(event.originalEvent.deltaY < 0);
    }
}

function handleChangePage() {
    setTimeout(function() {
        setAttr($win.scrollTop() === 0 ? '0' : '');
    }, 10);
}

function initFloatingHeaderMenu() {
    $win.on('popstate', handleChangePage);
    $win.on('tarantool.io-spa-move-to-page', handleChangePage);
    $win.on('wheel', $u.throttle(handleWheel, SCROLL_THROTTLE_TIMEOUT));
}

$(function() {
    setTimeout(initFloatingHeaderMenu, 100);
});
