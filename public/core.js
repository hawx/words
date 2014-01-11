var Alert = function(msg, count) {
    var show = function(text) {
        msg.html(text);
        count.hide();
        msg.show();
    }

    var hide = function() {
        msg.hide();
        count.show();
    }

    return {
        display: function(text, timeout) {
            show(text);
            setInterval(hide, timeout);
        }
    }
}

var Textarea = function(el) {
    el.autosize({
        'callback': function() {
            var pos = el.caret('pos');
            var len = el.val().length;

            if (pos === len) {
                window.scrollTo(0, document.body.scrollHeight);
            }
        }
    });

    el.simplyCountable({
        counter:        '#count',
        countType:      'words',
        wordSeperator:  ' ',
        maxCount:       desiredWordCount - 1,
        strictMax:      false,
        countDirection: 'up',
        safeClass:      '',
        overClass:      'passed'
    });

    return {
        save: function(callback) {
            $.ajax({
                type: 'POST',
                url:  '/save',
                data: {text: el.val()},
                success: callback
            });
        }
    }
}

$(function() {
    var textarea = new Textarea($('textarea'));
    var alert = new Alert($('#message'), $('#count'));

    Mousetrap.bind('ctrl+s', function(e) {
        textarea.save(alert.display('Saved!', 3000))
        return false;
    });

    var autosave = function() {
        textarea.save(alert.display('Autosaved!', 1500));
    }

    setInterval(autosave, 10 * 1000);
});
