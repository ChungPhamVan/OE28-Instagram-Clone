$(document).mouseup(function(e) {
  var container = $('div.notif');
  if (!container.is(e.target) && container.has(e.target).length === 0) {
    $('div.notif').removeClass('d-block');
  }
});
$(document).on('turbolinks:load', function() {
  $('div#notification_icon')
    .unbind('click')
    .on('click', function() {
      $('#count_unread_notif').hide();
      $('div.notif').toggleClass('d-block');
    });
  $(document).on('click', 'a.update_submit', function() {
      $(this)
        .parent()
        .find('.button_update_notif')
        .click();
      $(this).remove();
    });
  $(document).on('click', 'a.delete_submit', function() {
      $(this)
        .parent()
        .find('.button_delete_notif')
        .click();
    });
  $(document).on('click', 'a#mark_all_as_read', function() {
      $('.update_all_btn').click();
    });
  $(document).on('click', '.submit_delete_user', function() {
    var text = $('.sure_delete').html();
    return confirm(text);
  });
  $(document).on('click', '.follow_not_login', function() {
    var textAlert = $(this).next().html();
    alert(textAlert);
  });
});
