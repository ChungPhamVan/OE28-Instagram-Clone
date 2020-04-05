var loadData = require('packs/load_data');

$(document).ready(function() {
  var page = 1;
  var user_id = $('.user-profile').attr('data_id');
  var url = '/users/' + user_id + '/posts';
  loadData(url, { page: page });

  $(window).scroll(function() {
    if ($(window).scrollTop() == $(document).height() - $(window).height()) {
      page++;
      loadData(url, { page: page });
    }
  });
});

$(document).ready(function() {
  var page = 1;
  var sort_val;
  var text_search = "";
  var type = "";
  $('#load-more-posts-table').on('click', function() {
    url = '/admin/posts';
    page++;
    text_search = $('#search_input').val();
    loadData(url, { page: page, type: type, sort_value: sort_val, text_search: text_search });
  });
  $('.sort_btn').on('click', function() {
    page = 1;
    sort_val = $(".sort_value").val();
    url = '/admin/posts';
    type = "sort";
    loadData(url, { sort_value: sort_val, type: type, text_search: text_search });
  });
  $('#search_input').keyup(function(event) {
    url = '/admin/posts';
    text_search = $(this).val();
    type = "search";
    loadData(url, { type: type, text_search: text_search });
  }).keydown(function(event) {
    if ( event.which == 13 ) {
      event.preventDefault();
    }
  });
});
