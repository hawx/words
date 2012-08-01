function wordCount(s){
    s = s.replace(/(^\s*)|(\s*$)/gi, "");
    s = s.replace(/\n/gi, " ");
    s = s.replace(/[ ]{2,}/gi, " ");

    if (s == "") {
        return 0;
    }

    return s.split(' ').length;
}

function updateWordCount() {
    var area  = document.querySelector('textarea');
    var count = document.querySelectorAll('#count')[0];
    var words = wordCount(area.value);
    var str;

    if (words == 1) {
        str = "1 word";
    } else {
        str = words + " words";
    }

    count.innerText = str;

    if (words > desiredWordCount) {
        count.className = 'passed';
    } else {
        count.className = '';
    }
}

function makeExpandingArea(container) {
    var area  = container.querySelector('textarea');
    var span  = container.querySelector('span');
    var ab    = true;

    if (area.addEventListener) {
        area.addEventListener('input', function() {
            span.textContent = area.value;
            if (ab == true) {
              updateWordCount();
              ab = false;
            } else {
              ab = true;
            }
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

updateWordCount();

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
