window.addEventListener("message", function(event) {
    var v = event.data
    
    switch (v.action) {
        case 'openMenu':
            $('.container').fadeIn(100).css('display', 'flex');
        break;
    }
});


function CloseAll() {
    $('.container').fadeOut(100)
    $.post('https://bbv-shootingstyles/exit', JSON.stringify({}));
}

$(document).keyup((e) => {
    if (e.key === "Escape") {
        CloseAll()
    }
});