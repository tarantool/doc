$(function() {
  var open = 'dropdown-open';
  var close = 'dropdown-close';
  var download_drop_item = '.dropdown-list-item-url';
  var download_drop_item_parent = '.dropdown-list-item';
  var download_drop_box = '.dropdown-list-item-content';
  var dropdown_list = '.dropdown-list';

  var os = $.ua.os;

  if ($(download_drop_item)) {
    var download_drop_items = $(download_drop_item);
    for (var i=0; i<download_drop_items.length; i++) {
      if ($(download_drop_items[i]).parents(download_drop_item_parent).find(download_drop_box).length != 0) {
        $(download_drop_items[i]).addClass(close);
      }
    };

    if (os) {
      var isFound = false;

      for (var i=0; i<download_drop_items.length; i++) {
        if (!isFound && download_drop_items[i].text.toLowerCase().indexOf(getTabNameForOS(os)) != -1) {
          $(download_drop_items[i]).addClass(open);
          $(download_drop_items[i]).parents(download_drop_item_parent).find(download_drop_box).addClass(open);

          var dropdown_list = $(download_drop_items[i]).parents(dropdown_list);
          $(dropdown_list).prepend($(download_drop_items[i]).parents(download_drop_item_parent));

          isFound = true;
        }
      };
    }
  }

  $(download_drop_item).click(function() {
    if($(this).parents(download_drop_item_parent).find(download_drop_box).length!=0) {
      if ($(this).hasClass(open)) {
        $(this).removeClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(close);
      } else {
        $(this).addClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(open);
        $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(close);
      }
    }
    return false;
  });
});

function getOSName(os) {
  switch (os.name.toLowerCase()) {
    case 'mac os':
      return 'os x';
    case 'debian':
      if (/^7/.test(os.version)) return 'wheezy';
      return 'jessie';
    case 'centos':
      return 'centos 7';
    case 'rhel':
      return 'rhel 7';
    case 'linux':
      return 'ubuntu';
    default:
      return os.name.toLowerCase();
  }
}

function getTabNameForOS(os) {
  var name = getOSName(os);

  for (var i=0; i<tarantool_platforms.length; i++) {
    if (tarantool_platforms[i].indexOf(name) != -1) {
      return name;
    }
  }

  for (var i=0; i<docker_platforms.length; i++) {
    if (docker_platforms[i].indexOf(name) != -1) {
      return 'docker';
    }
  }

  return 'unknown';
}

var docker_platforms = ['os x', 'windows', 'centos', 'debian', 'fedora', 'ubuntu', 'aws', 'azure'];

var tarantool_platforms = [
  'ubuntu',
  'jessie',
  'stretch',
  'wheezy',
  'fedora',
  'rhel 6',
  'rhel 7',
  'centos 6',
  'centos 7',
  'debian',
  'amazon linux',
  'os x',
  'freebsd',
  'microsoft azure'
];
