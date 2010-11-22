$(function(){

  // Initialize Shadowbox.
  if(Shadowbox) {
    Shadowbox.init({ skipSetup: true });
    Shadowbox.setup();
  }

  // Links with rel=sideload will sideload a release to a users own
  // music collection.
  $('a[rel=sideload]').livequery('click', function(e){
    e.preventDefault();
    if(confirm('Are you sure?')) {
      var self = $(this);
      $.post(this.href, null, function(){
        self.hide('fast');
      });
    }
  });

  $('.new_comment').livequery(function(){
    $(this).validate({
      submitHandler: function(form) {
        $(form).find('.submitrow').hide();
        $(form).ajaxSubmit({
          success: function(){
            var now = new Date();
            $('<li><a class="user" target="_blank"></a><abbr class="timestamp"></abbr><p></p></li>')
              .find('a.user').text($('.new_comment').attr('data-username')).attr('href', '/'+$('.new_comment').attr('data-username')).end()
              .find('abbr.timestamp').attr('title',now.toUTCString()).text(human_date(now.toUTCString())).end()
              .find('p').text($('.new_comment textarea').val()).end()
              .hide().appendTo($('.comments')).fadeIn('fast');
            $('.new_comment textarea').val('').height('16px');
          }
        });
      }
    });
  });

  $('.new_comment textarea').livequery(function(){
    $(this)
    .focus(function(e){
      $('.new_comment .submitrow').show('fast');
    })
    .blur(function(e){
      setTimeout(function(){
        $('.new_comment .submitrow').hide('fast');
      }, 500);
    });
  });

  $('.hinted').livequery(function(){
    $(this).inputHint();
  });

  $('.autogrow').livequery(function(){
    $(this).autogrow();
  });

  $('.timestamp').livequery(function(){
    $(this).text(human_date($(this).attr('title')));
  });

  setInterval(function(){
    $('.timestamp').each(function(){
      $(this).text(human_date($(this).attr('title')));
    });
  }, 5000);

});