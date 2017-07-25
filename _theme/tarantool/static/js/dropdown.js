$(function() {
  // var open = 'dropdown-open';
  // var close = 'dropdown-close';
  // var download_drop_item = '.dropdown-list-item-url';
  // var download_drop_item_parent = '.dropdown-list-item';
  // var download_drop_box = '.dropdown-list-item-content';
  // var dropdown_list = '.dropdown-list';

  // var download_block_button = '.b-download-block-button';
  var os_install_block = '#os-install';
  var learn_more_button = $(os_install_block).find('a');

  var os = $.ua.os;

  console.log('SCRIPT', os_install_block, learn_more_button);

  learn_more_button.click(function(e) {
    e.preventDefault();

    console.log('CLICK');

    var os_name = getOSName(os);
    var keys = Object.keys(os_installation_page_names);

    for (var i = 0; i < keys.length; i++) {

      console.log('FIRST FOR', i);
      if (os_name.indexOf(keys[i]) != -1) {
        console.log('FOUND', os_installation_page_names[keys[i]]);
        window.location.replace('download/os-installation/' + os_installation_page_names[keys[i]] + '.html');
        return;
      }
    }

    for (var i = 0; i < docker_platforms.length; i++) {
      console.log('DOCKER FOR', i);
      if (docker_platforms[i].indexOf(os_name) != -1) {
        console.log('FOUND IN DOCKER');
        window.location.replace('download/os-installation/' + os_installation_page_names['docker'] + '.html');
        return;
      }
    }
  });

  // ------------------------------------------------------------------

  // var os = $.ua.os;
  //
  // if ($(download_drop_item)) {
  //   var download_drop_items = $(download_drop_item);
  //   for (var i=0; i<download_drop_items.length; i++) {
  //     if ($(download_drop_items[i]).parents(download_drop_item_parent).find(download_drop_box).length != 0) {
  //       $(download_drop_items[i]).addClass(close);
  //     }
  //   };
  //
  //   if (os) {
  //     var isFound = false;
  //
  //     for (var i=0; i<download_drop_items.length; i++) {
  //       if (!isFound && download_drop_items[i].text.toLowerCase().indexOf(getTabNameForOS(os)) != -1) {
  //         $(download_drop_items[i]).addClass(open);
  //         $(download_drop_items[i]).parents(download_drop_item_parent).find(download_drop_box).addClass(open);
  //
  //         var dropdown_list = $(download_drop_items[i]).parents(dropdown_list);
  //         $(dropdown_list).prepend($(download_drop_items[i]).parents(download_drop_item_parent));
  //
  //         isFound = true;
  //       }
  //     };
  //   }
  // }
  //
  // $(download_drop_item).click(function() {
  //   if($(this).parents(download_drop_item_parent).find(download_drop_box).length!=0) {
  //     if ($(this).hasClass(open)) {
  //       $(this).removeClass(open);
  //       $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(open);
  //       $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(close);
  //     } else {
  //       $(this).addClass(open);
  //       $(this).parents(download_drop_item_parent).find(download_drop_box).addClass(open);
  //       $(this).parents(download_drop_item_parent).find(download_drop_box).removeClass(close);
  //     }
  //   }
  //   return false;
  // });
  //
  // $(function() {
  //   console.log("opening tabs");
  //   var hash = $(location).attr('hash');
  //   console.log(hash);
  //   if (hash.match('^#node')) {
  //     console.log($(hash));
  //     console.log($(hash).text());
  //     $(hash).click();
  //   }
  // });

});

var os_installation_page_names = new Object();
os_installation_page_names.ubuntu = 'ubuntu';
os_installation_page_names.amazon = 'amazon-linux';
os_installation_page_names.source = 'building-from-source';
os_installation_page_names.jessie = 'debian-stretch-jessie-and-newer';
os_installation_page_names.wheezy = 'debian-wheezy';
os_installation_page_names.docker = 'docker-hub';
os_installation_page_names.fedora = 'fedora';
os_installation_page_names.freebsd = 'freebsd';
os_installation_page_names.azure = 'microsoft-azure';
os_installation_page_names.mac = 'os-x';
os_installation_page_names.rhel6 = 'rhel-6-and-cent-os-6';
os_installation_page_names.rhel7 = 'rhel-7-and-cent-os-7';
os_installation_page_names.snappy = 'snappy-package';

var docker_platforms = ['os x', 'windows', 'centos', 'debian', 'fedora', 'ubuntu', 'aws', 'azure'];

// var tarantool_platforms = [
//   'ubuntu',
//   'jessie',
//   'stretch',
//   'wheezy',
//   'fedora',
//   'rhel 6',
//   'rhel 7',
//   'centos 6',
//   'centos 7',
//   'debian',
//   'amazon linux',
//   'os x',
//   'freebsd',
//   'microsoft azure'
// ];
function getOSName(os) {
  switch (os.name.toLowerCase()) {
    case 'mac os':
      // return 'os x';
      return 'mac';
    case 'debian':
      if (/^7/.test(os.version)) return 'wheezy';
      return 'jessie';
    case 'centos':
      return 'centos7';
    case 'rhel':
      return 'rhel7';
    case 'linux':
      return 'ubuntu';
    default:
      return os.name.toLowerCase();
  }
}

// function getTabNameForOS(os) {
//   var name = getOSName(os);
//
//   for (var i=0; i<tarantool_platforms.length; i++) {
//     if (tarantool_platforms[i].indexOf(name) != -1) {
//       return name;
//     }
//   }
//
//   for (var i=0; i<docker_platforms.length; i++) {
//     if (docker_platforms[i].indexOf(name) != -1) {
//       return 'docker';
//     }
//   }
//
//   return 'unknown';
// }
