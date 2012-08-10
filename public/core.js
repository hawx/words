$(document).ready(function() {

  var cont = $('#container'),
      area = $('#the_area'),
      span = $('#the_span');

  area.simplyCountable({
    counter:        '#count',
    countType:      'words',
    wordSeperator:  ' ',
    maxCount:       desiredWordCount - 1,
    strictMax:      false,
    countDirection: 'up',
    safeClass:      '',
    overClass:      'passed'
  });
      
  area.on('input', function() {
    span.html(area.val());
  });
  span.html(area.val());
  
  cont.addClass('active');

  function saveTheText(cb) {
    $.ajax({
      type: 'POST',
      url:  '/save',
      data: {
        text: $('#the_area').val()
      },
      success: cb
    });
  }
  
  function autosaveTheText() {
    saveTheText(function() {
      showAlert('Autosaved');
      setInterval(hideAlert, 1000);
    });
    setInterval(autosaveTheText, 20 * 1000);
  }
  
  setInterval(autosaveTheText, 20 * 1000);

  function showAlert(text) {
    var msg = $('#message'), count = $('#count');
    msg.html(text);
    count.hide();
    msg.show();
  }
  
  function hideAlert() {
    var msg = $('#message'), count = $('#count');
    msg.hide();
    count.show();
  }
  
  Mousetrap.bind('ctrl+s', function(e) {
    saveTheText(function() {
      showAlert('Saved!');
      setInterval(hideAlert, 3000);
    });
    return false;
  });
  
});
