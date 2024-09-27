function getParent(el) {
    var $el = $(el);
    var $parent = $el.is("li") ? $el : $el.parent();
    return $parent && $parent.is("li") ? $parent : undefined;
}

function setOpenedState(el, opened) {
    var $parent = getParent(el);
    if (!$parent) {
        return;
    }

    $parent.data('opened', opened ? 'true' : 'false');

    if (opened) {
        $parent.find('> ul').toggle(true);
        $parent.find('> i.fa')
            .toggleClass('fa-caret-up', true)
            .toggleClass('fa-caret-down', false);

        var $parentUl = $parent.closest('ul', '[data-component="menu-left"]');
        if ($parentUl && $parentUl.is('ul')) {
            setOpenedState($parentUl, true);
        }
    } else {
        $parent.find('ul').toggle(false);
        $parent.find('i.fa')
            .toggleClass('fa-caret-up', false)
            .toggleClass('fa-caret-down', true);
    }
};

function initToggleState(el) {
    var $parent = getParent(el);
    if (!$parent) {
        return;
    }

    setOpenedState(el, $parent.data('opened') !== 'true');
};


function initLeftMenu() {
    var $menuLeft = $('[data-component="menu-left"]');
    // add arrows
    $menuLeft.find('li > ul').after("<i class='fa fa-caret-down'></i>");

    var $links = $menuLeft.find('a');
    var $current = $menuLeft.find('a.current');
    var $arrows = $menuLeft.find('a + ul + i.fa');

    $links.on('click', function(event) {
        if ($(this).is('a.current')) {
            event.preventDefault();
            initToggleState(this);
        }
    });

    $arrows.on('click', function() {
        initToggleState(this);
    });

    setOpenedState($current, true);
}

function initScrollToSelected() {
    var $menuLeft = $('[data-component="menu-left"]');
    var $current = $menuLeft.find('a.current');

    if ($current.length !== 1 || $current.offset().top < $(window).height()) {
        return;
    }

    $menuLeft.scrollTo($current);
}

$(function() {
    setTimeout(initLeftMenu, 10);
    setTimeout(initScrollToSelected, 300);
});
