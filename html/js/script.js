$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "open") {
            bbyRadio.SlideUp()
        }

        if (event.data.type == "close") {
            bbyRadio.SlideDown()
        }
    });

    document.onkeyup = function (data) {
        if (data.key == "Escape") { // Escape key
            $.post('https://bby-radio/escape', JSON.stringify({}));
        } else if (data.key == "Enter") { // Enter key
            $.post('https://bby-radio/joinRadio', JSON.stringify({
                channel: $("#channel").val()
            }));
        }
    };
});

bbyRadio = {}

$(document).on('click', '#submit', function(e){
    e.preventDefault();

    $.post('https://bby-radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#disconnect', function(e){
    e.preventDefault();

    $.post('https://bby-radio/leaveRadio');
});

$(document).on('click', '#volumeUp', function(e){
    e.preventDefault();

    $.post('https://bby-radio/volumeUp', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#volumeDown', function(e){
    e.preventDefault();

    $.post('https://bby-radio/volumeDown', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#decreaseradiochannel', function(e){
    e.preventDefault();

    $.post('https://bby-radio/decreaseradiochannel', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#increaseradiochannel', function(e){
    e.preventDefault();

    $.post('https://bby-radio/increaseradiochannel', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#poweredOff', function(e){
    e.preventDefault();

    $.post('https://bby-radio/poweredOff', JSON.stringify({
        channel: $("#channel").val()
    }));
});

bbyRadio.SlideUp = function() {
    $(".container").css("display", "block");
    $(".radio-container").animate({bottom: "0vh",}, 250);
}

bbyRadio.SlideDown = function() {
    $(".radio-container").animate({bottom: "-110vh",}, 400, function(){
        $(".container").css("display", "none");
    });
}
