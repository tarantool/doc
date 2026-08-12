var HEADER_HIGHT = 120; // css: .b-article [id] -> scroll-margin-top: 120px;

var watchSideColumnMaxHeightOnScroll = $u.throttle(function() {
    var sideMenu = document.querySelector('[data-component="menu-right"] .doc-content__side-menu');
    if (sideMenu) {
        var innerHeight = window.innerHeight;
        var top = sideMenu.getBoundingClientRect().top;

        if (top > 0 && innerHeight > 0 && innerHeight > top) {
            sideMenu.style.maxHeight = String(innerHeight - top) + 'px';
        } else {
            sideMenu.style.maxHeight = '100vh';
        }
    }
}, 300);

function watchSideColumnMaxHeightOnToggleHeaderVisibility() {
    watchSideColumnMaxHeightOnScroll();
    setTimeout(watchSideColumnMaxHeightOnScroll, 300);
};

function watchSideColumnMaxHeight() {
    window.removeEventListener('resize', watchSideColumnMaxHeightOnScroll);
    window.addEventListener('resize', watchSideColumnMaxHeightOnScroll);
    window.removeEventListener('scroll', watchSideColumnMaxHeightOnScroll);
    window.addEventListener('scroll', watchSideColumnMaxHeightOnScroll);

    $(window).off('tarantool.io-toggle-data-hidden-header', watchSideColumnMaxHeightOnToggleHeaderVisibility);
    $(window).on('tarantool.io-toggle-data-hidden-header', watchSideColumnMaxHeightOnToggleHeaderVisibility);
}

function createSideMenu() {
    const $sideMenu = document.querySelector('.doc-content__side-column-content');
    const $firstSection = document.querySelector('.section');
    
    if ($sideMenu && $firstSection) {
        const innerSections = Array.from($firstSection.children).filter((s)=> Array.from(s.classList).includes('section'))
        const $menu = document.createElement('div');
        const $menuList = document.createElement('div');
        $menu.classList.add('doc-content__side-menu');
        $menuList.classList.add('doc-content__side-menu-list');
        if (innerSections.length > 0) {
            const menuSections = getSections($firstSection, innerSections, undefined);
            const createMenuElements = (sections, $parent) => {
                sections.forEach((section) => {
                    const $link = document.createElement('a');
                    $link.innerText = section.title;
                    $link.href = `#${section.id}`;
                    $link.classList.add('side-menu__link');
                    
                    const $menuItem = document.createElement('div');

                    $menuItem.appendChild($link);
                    if(section.subSections.length>0) {
                        const $subItems = document.createElement('div');
                        $subItems.classList.add('side-menu__submenu');
                        $menuItem.appendChild($subItems);
                        createMenuElements(section.subSections, $subItems);
                    }
                    $parent.appendChild($menuItem);
                })
            }
            createMenuElements(menuSections, $menuList);
            $menu.appendChild($menuList);
            $sideMenu.appendChild($menu);
        }
    };
};

var menuTitles = [];
function getSections(section, innerSections, parentId) { // section: Element, innerSection: NodeListOf<Element>
    var $h1 = section.querySelector('h1')
    var changedSections = [];
    if ($h1 !== null && parentId === undefined && innerSections.length > 0) {
        menuTitles.splice(0, menuTitles.length);
        innerSections.forEach((s) => {
            var subSections = Array.from(s.children).filter((ss) => Array.from(ss.classList).includes('section'))
            getSections(s, subSections, undefined);
        });
    } else {
        var sectionId = section.getAttribute('id')
        var $title = section.querySelector('.b-doc-hlink_right');
        if ($title) {
            var title = $title.innerText
            if (parentId === undefined) {
                menuTitles.push({
                    id: sectionId,
                    title: title,
                    subSections: [],
                })
            } else {
                var changeSections = (sections) => {
                    var parentIndex = sections.findIndex((item) => item.id === parentId);
                    if (parentIndex >= 0) {
                        return sections.map((s, index) => {
                            if (index === parentIndex) {
                                return {
                                    ...s,
                                    subSections: s.subSections.push({
                                        id: sectionId,
                                        title: title,
                                        subSections: []
                                    })
                                }
                            } else {
                                return s
                            }
                        })
                    } else {
                        return sections.map((s) => ({
                            ...s,
                            subSections: s.subSections.length>0 ? changeSections(s.subSections) : s.subSections,
                        }))
                    }
                }
                changedSections.push(changeSections(menuTitles));
            }
        }
        innerSections.forEach((s)=>{
            var subSections = Array.from(s.children).filter((ss)=> Array.from(ss.classList).includes('section'))
            getSections(s, subSections, sectionId);
        });
    }
    return changedSections.length>0? changedSections : menuTitles;
};

function selectMenuAndOpenSubmenus($link) {
    $link.classList.add('side-menu_current');

    var activeSubmenu = Array.from(document.querySelectorAll('.side-menu__submenu_visible'));
    if (activeSubmenu.length > 0) {
        activeSubmenu.forEach((item) => {
            const linkInItem = Array.from(item.querySelectorAll('.side-menu_current'));
            if (linkInItem.length) {
                if (!linkInItem.includes($link)) {
                    item.classList.remove('side-menu__submenu_visible')
                }
            } else {
                item.classList.remove('side-menu__submenu_visible')
            }
        })
    }
    var $submenu = $link.parentElement.parentElement;
    if ($submenu && Array.from($submenu.classList).includes('side-menu__submenu')) {
        $submenu.classList.add('side-menu__submenu_visible');
    }
    var $childSubmenu = Array.from($link.parentElement.children).find((child) => Array.from(child.classList).includes('side-menu__submenu')) 
    if ($childSubmenu){
        $childSubmenu.classList.add('side-menu__submenu_visible');
    }
};

var getCurrentBlock = $u.throttle(function() {
    var sections = Array.from(document.querySelectorAll('.section'));
    var links = Array.from(document.querySelectorAll('.side-menu__link'));

    if (sections.length === 0 || links.length === 0) {
        return;
    }

    var last = sections.reduce((acc, block) => {
        return block.getBoundingClientRect().top < HEADER_HIGHT + 1 ? block : acc;
    });

    if (last) {
        var lastId = `#${last.getAttribute('id')}`;
        var selectedLink = links.reduce((acc, link) => {
            return link.getAttribute('href') === lastId ? link : acc;
        });

        links.forEach((link) => link.classList.remove('side-menu_current'));
        if (selectedLink) {
            selectMenuAndOpenSubmenus(selectedLink);
        }
    }
}, 100);

$(function() {
    setTimeout(function() {
        createSideMenu();
        getCurrentBlock();
        watchSideColumnMaxHeight();
        window.addEventListener('scroll', getCurrentBlock);
    }, 200);
});