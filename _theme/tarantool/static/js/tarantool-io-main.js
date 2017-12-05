$(function(){
    var $containerCollapse = $('#container-collapse');
    $containerCollapse.css('display', 'none');

    $(window).resize(function(){
        setJumboPostion($(this).width());
    });

    function setJumboPostion(width){
        if(width < 768) {
            $('.jumbotron').css({
                // 'background-image': 'url("/web/assets/images/banners/mobile_jumbo.jpg")',
                'background-position': '34% 50%'
            });
        } else {
            $('.jumbotron').css({
                // 'background-image':'url("/web/assets/images/banners/Sized%20Jumbotron%20Still.png")',
                'background-position': '50%'
            });
        }
    }

    //set background image
    if (window.location.pathname === "/") {
        setJumboPostion($(this).width());
    } else if (window.location.pathname ===  "/unwired" || window.location.pathname ===  "/product/unwired-iiot") {
        $('.jumbotron').css('border-bottom', '4px solid #ff6600');
    } else if (window.location.pathname ===  "/developers") {
        Particles.init({
            selector: '.particle-js',
            connectParticles: true,
            color: '#ffffff'
        });
        $('.jumbotron').css('border-bottom', '4px solid red');
    }

    $('.carousel').carousel({
        interval: 5000,
        pause: 'false'
    });


    $('#myCarousel').carousel({
        interval: 12000,
        pause: 'false'
    });

    //mobile nav dropdown
    $('body:not(#container-collapse)').on('click touch',function(e) {
        var targetEl = e.target;
        var $menuButton = $('#menu-button');

        if (targetEl === $menuButton[0]) {
            if ($containerCollapse.attr('style') === "display: none;") {
                $containerCollapse.css('display', 'block');
                $menuButton.css({
                    'background-color': 'white',
                    'color': 'black',
                    'border': 'white'
                });
            }else {
                $containerCollapse.css('display', 'none');
                $menuButton.css({
                   'background-color': 'black',
                    'color': 'white',
                    'border': '1px solid black'
                });
            }
        }else {
            if ($containerCollapse.attr('style') === "display: block;") {
                $containerCollapse.css('display', 'none');
                $menuButton.css({
                    'background-color': 'black',
                    'color': 'white',
                    'border': '1px solid black'
                });
            }
        }
    });

    $('.why-button').on('click touch', function(){
        console.log('click');
        rotate(this);
    });

    $('.why-button').hover(function(){
        rotate(this);
    });

    //rotate cards
    function rotate(el) {
        $('.flip-container').scrollTop(0).css('overflow', 'hidden');
        $('.flipper').removeClass('rotate').css('overflow', '');
        var $flipper = $($(el)[0]).parent().parent().parent().parent();
        $flipper.parent().css('overflow-y', 'auto');
        $flipper.addClass('rotate');
    }

    //nav color swap
    // $(window).scroll(function(){
    //     if(window.location.search !== "?page=try-it") {
    //         if($(this).scrollTop() > 68) {
    //             $('#header-nav').css('background-color', 'black');
    //         }else{
    //             $('#header-nav').css('background-color', 'transparent');
    //         }
    //     }
    // });
    $(window).resize(function(){
        if($(this).width() > 767) {
            $('#container-collapse').css('display', 'none');
        }
    });

    $('form button').click(function(){
        $('.error-message').remove();
        var $this = $(this);
        $this.button('loading');
        $form = $this.parent().parent().parent();
        $form.find('input').css('border', 'none');

        var data = {
            first_name: $form.find('[name="first_name"]').val(),
            last_name: $form.find('[name="last_name"]').val(),
            email: $form.find('[name="email"]').val(),
            phone: $form.find('[name="phone"]').val(),
            company_name: $form.find('[name="company_name"]').val()
        };

        //form validation
        var errorFieldsArray = [];
        for (var i in data) {
            if ($.trim(data[i]) == '') {
               errorFieldsArray.push(i);
            }
        }
        if (errorFieldsArray.length > 0) {
            $this.parent().parent().prepend('<p class="text-center error-message" style="color: red !important; position: absolute; left: 50%; transform: translateX(-50%); width: 100%;">Please fill out the required fields.</p>');
           for (var x = 0; x < errorFieldsArray.length; x++) {
               $('[name='+errorFieldsArray[x]+']').css('border', '2px solid red');
           }
           $this.button('reset');
           return;
        }

        data.message = $form.find('[name="message"]').val();
        data.customer_interest = window.location.pathname === "/live-demo" ?
            $form.find('[name="customer_interest"]:checked').val()  :
            $form.find('[name="customer_interest"]').val();
        data.live_demo = $form.find('[name="live_demo"]').val();

        // Must be removed
        alert(JSON.stringify(data));
        return true;
        // Must be removed

        $.ajax({
            url: '/src/php/demo-request.php',
            dataType: 'json',
            method: 'POST',
            data: data,
            success: function(response) {
                console.log('success', response);
                if (response.success) {
                    ga('send', 'event', 'Form', 'Submit', 'Submission');
                    $this.parent().replaceWith( "<div class='col-xs-12'><p style='color: #259427 !important; font-size: 1.2em !important; position: relative; top: 0.3em; text-align: center'>Thanks for sending a message to our team. We will email shortly.</p></div>" );
                    if (typeof form_submission_success === "function") { 
                        form_submission_success();
                    }
                } else {
                    $this.parent().replaceWith( "<div class='col-xs-12'><p style='color: #259427 !important; font-size: 1.2em !important; position: relative; top: 0.3em; text-align: center'>An error has occured, please contact the Tarantool team directly via phone.</p></div>");
                }
                $('form input, form textarea').val('');
            },
            error: function(rejection) {
                $this.parent().replaceWith( "<div class='col-xs-12'><p style='color: red !important; text-align: center'>An error has occured, please contact the Tarantool team directly via phone.</p></div>");
            }
        });
    });


    //FUNCTION TO GET AND AUTO PLAY YOUTUBE VIDEO FROM DATATAG
    var trigger = $("body").find('[data-toggle="modal"]');
    trigger.click(function () {
        var theModal = $(this).data("target"),
            videoSRC = $(this).attr("data-theVideo"),
            videoSRCauto = videoSRC + "?autoplay=1&controls=0&loop=1&rel=0";

        console.log('video src', videoSRC);
        // https://www.youtube.com/embed/cw4wcQg-iPQ

        $(theModal).on('hidden.bs.modal', function () {
           $('video').show();
            $('.carousel').carousel({
                interval: 2400,
                pause: 'false'
            });

            $('#myCarousel').carousel({
                interval: 3000,
                pause: 'false'
            });
        });

        $(theModal).on('shown.bs.modal', function () {
            $('video').hide();
        });

        $(theModal + ' iframe').attr('src', videoSRCauto);
        $(theModal + ' button.close').click(function () {
            $(theModal + ' iframe').attr('src', videoSRC);
        });
        $('.modal').click(function () {
            $(theModal + ' iframe').attr('src', videoSRC);
        });
    });

    //career panels
    $('.panel-default').click(function(){
        if ($(this).find('[data-toggle="collapse"]').attr('aria-expanded') === 'true') {
            $(this).find('.fa-chevron-down').show();
            return;
        }

        $(this).find('.fa-chevron-down').hide();
    });

    //maps
    var latLng = {
        siliconValley: {
            lat: 37.406714, lng: -122.109072
        },
        Moscow: {
            lat: 55.797896, lng: 37.537427
        },
        Amsterdam: {
            lat: 52.336740, lng: 4.885585
        }
    };

    function initMap(latLong) {
        // Create a map object and specify the DOM element for display.
        var map = new google.maps.Map(document.getElementById('map'), {
            center: latLong,
            scrollwheel: false,
            zoom: 18
        });

        // Create a marker and set its position.
        var marker = new google.maps.Marker({
            map: map,
            position: latLong
        });
    }

    if (window.location.pathname.match(/\/contact/g) || window.location.pathname.match(/\/about/g) ) {
        initMap(latLng.siliconValley);

        $('.map-trigger').click(function(){
            $('.contact-btn').removeClass('btn-active');
            var key = $(this).attr('data-key');
            var buttonTarget = '.contact-btn[data-key='+key+']';
            $(buttonTarget).addClass('btn-active');
            var coordinates = latLng[key];

            initMap(coordinates);
        });
    }

    function initDownloadSection() {
        $("#main-content").load("/web/assets/templates/developers/downloads/docker-18.php", function (responseTxt, statusTxt, xhr) {
            $('.download-trigger').click(function () {
                var id = $(this).attr('id');
                if (id === 'docker') {
                    id+='-18';
                    console.log('id:', id);
                }
                $("#main-content").load("/web/assets/templates/developers/downloads/" + id + ".php", function (responseTxt, statusTxt, xhr) {
                    console.log('loaded');
                });
            });
        });
    }
    initDownloadSection();
});
