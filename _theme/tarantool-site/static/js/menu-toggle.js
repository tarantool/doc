function showMenu() {
  var heroBlock = document.getElementById('hero_block');
  if (heroBlock) {
      heroBlock.classList.add('hidden');
  }

  var togglemenubtn = document.getElementById('togglemenubtn');
  if (togglemenubtn) {
    togglemenubtn.classList.add('active');
  }
  
  var dropdownmenu = document.getElementById('dropdownmenu');
  if (dropdownmenu) {
    dropdownmenu.classList.add('active');
    document.body.style.overflow = "hidden";
    $('html').attr('data-header-dropdown-menu-is-active', '1');
  }
}

function hideMenu() {
  var heroBlock = document.getElementById('hero_block');
  if (heroBlock) {
    heroBlock.classList.remove('hidden');
  }

  var togglemenubtn = document.getElementById('togglemenubtn');
  if (togglemenubtn) {
    togglemenubtn.classList.remove('active');
  }

  var dropdownmenu = document.getElementById('dropdownmenu');
  if (dropdownmenu) {
    dropdownmenu.classList.remove('active');
    document.body.style.overflow = "auto";
    $('html').attr('data-header-dropdown-menu-is-active', '0');
  }
}

function toggleMenu() {
  var dropdownmenu = document.getElementById('dropdownmenu');
  if (dropdownmenu) {
    if (dropdownmenu.classList.value.match(/active/g)) {
      hideMenu();
    } else {
      showMenu();
    }
  }
};

function toggleSearch() {
  var searchmenu = document.getElementById('searchmenu');
  if (searchmenu) {
    searchmenu.classList.add('doc-header__search_visible');
  }

  var searchclose = document.getElementById('search_close');
  if (searchclose) {
    searchclose.classList.add('doc-header__search-close_visible');
  }
};

function closeSearch() {  
  var searchmenu = document.getElementById('searchmenu');
  if (searchmenu) {
    searchmenu.classList.remove('doc-header__search_visible');
  }
  
  var searchclose = document.getElementById('search_close');
  if (searchclose) {
    searchclose.classList.remove('doc-header__search-close_visible');
  }
};

if (typeof window !== 'undefined') {
  window.addEventListener('resize', $u.throttle(hideMenu, 300));
}

$(function() {
  setTimeout(function() {
    var togglemenubtn = document.getElementById('togglemenubtn');
    if (togglemenubtn) {
      togglemenubtn.onclick = toggleMenu;
    }
    
    var togglesearchbtn = document.getElementById('togglesearchbtn');
    if (togglesearchbtn) {
      togglesearchbtn.onclick = toggleSearch;
    }
    
    var searchclose = document.getElementById('search_close');
    if (searchclose) {
      searchclose.onclick = closeSearch;
    };
  }, 100);
});
