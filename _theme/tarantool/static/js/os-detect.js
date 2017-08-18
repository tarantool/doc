$(function() {
  if (!window.location.href.includes('download/download')) return;

  var os_install_block = '.packages';
  var learn_more_button = $($(os_install_block).find('.b-download-block-button'));

  var detected_instruction = getInstruction();

  if (detected_instruction != 'unknown') {
    learn_more_button.attr("href", detected_instruction);
  }

  // Replacing general-download block content with detected instruction.
  var general_download = $('.b-general-download');
  var general_block_title = $('.b-general-download-title');
  var general_block_description = $('.b-general-download-description');
  var general_learn_more_button = $(general_download.find('.b-download-block-button'));

  var detected_instruction_title;
  var detected_instruction_text;

  if (detected_instruction != 'unknown') {
    $.ajax({
      url: detected_instruction,
      type:'GET',
      success: function(data) {
         detected_instruction_title = $(data).find('.b-section-title').html();
         detected_instruction_text = $($(data).find('.b-os-installation-content'));

         detected_instruction_text.find('.b-section-title').remove();
         detected_instruction_text.find('.highlight-bash').remove();
         detected_instruction_text = $(detected_instruction_text.find('p')[0]);

         $(general_block_title.find('a')).attr('href', detected_instruction);
         $(general_block_title.find('a')).text(detected_instruction_title);

         general_block_description.html(detected_instruction_text.html());

         if (detected_instruction.includes('docker')) $(general_learn_more_button.find('a')).attr("href", "https://hub.docker.com/r/tarantool/tarantool/");
         else $(general_learn_more_button.find('a')).attr("href", detected_instruction);
      }
    });
  }
  // else {
  //   $(general_learn_more_button.find('a')).attr("href", "https://hub.docker.com/r/tarantool/tarantool/");
  // }

  general_learn_more_button.show();
  general_block_title.show();
  general_block_description.show();

});

function getInstruction() {
  var version = getVersion();

  var os = $.ua.os;
  var os_name = getOSName(os);

  var keys = Object.keys(os_installation_page_names);
  for (var i = 0; i < keys.length; i++) {
    if (os_name.indexOf(keys[i]) != -1) {
      return 'os-installation/' + version + '/' + os_installation_page_names[keys[i]] + '.html';
    }
  }

  // for (var i = 0; i < docker_platforms.length; i++) {
  //   if (docker_platforms[i].indexOf(os_name) != -1) {
  //     return 'os-installation/' + version + '/' + os_installation_page_names['docker'] + '.html';
  //   }
  // }

  return 'os-installation/' + version + '/' + os_installation_page_names['docker'] + '.html';
  // return 'unknown';
}

function getVersion() {
  if (window.location.href.includes('16')) return '1.6';
  if (window.location.href.includes('18')) return '1.8';
  return '1.7';
}

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
