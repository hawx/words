$(document).ready(function() {
  $("#the_area").simplyCountable({
    counter:        '#count',
    countType:      'words',
    wordSeperator:  ' ',
    maxCount:       desiredWordCount - 1,
    strictMax:      false,
    countDirection: 'up',
    safeClass:      '',
    overClass:      'passed'
  });
});

function makeExpandingArea(container) {
    var area  = container.querySelector('textarea');
    var span  = container.querySelector('span');

    if (area.addEventListener) {
        area.addEventListener('input', function() {
            span.textContent = area.value;
        }, false);
        span.textContent = area.value;
    } else if (area.attachEvent) {
        // IE8 compatibility
        area.attachEvent('onpropertychange', function() {
            span.innerText = area.value;
        });
        span.innerText = area.value;
    }
    // Enable extra CSS
    container.className += ' active';
}

var areas = document.querySelectorAll('.expandingArea');
var l = areas.length;

while (l--) {
    makeExpandingArea(areas[l]);
}

function saveTheText() {
    var text = document.querySelector('textarea').value;

    var http   = new XMLHttpRequest();
    var url    = "/";
    var params = "text=" + encodeURIComponent(text);

    http.open("POST", url, true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.send(params);
}

function autosaveTheText() {
    saveTheText();
    setInterval(autosaveTheText, 20 * 1000);
}

autosaveTheText();

function showAlert(text) {
    var count = document.querySelector('#count');
    count.innerText = text;
    count.className = 'flash';
}

function hideAlert() {
    var count = document.querySelector('#count');
    count.className = '';
    updateWordCount();
}

Mousetrap.bind('ctrl+s', function(e) {
    saveTheText();
    showAlert('Saved!');
    setInterval(hideAlert, 3000);

    return false;
});
