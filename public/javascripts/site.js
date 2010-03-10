$(function(){
  
  if(Shadowbox) {
    Shadowbox.init({ skipSetup: true });
    Shadowbox.setup();
  }
  
  $('#invitation_request_email').inputHint({ hintAttr: 'hint' });
  $('#new_invitation_request').validate();
  
  $('.tooltipped').tipsy({ gravity: 's' });
  $('.save-elsewhere a').tipsy({ gravity: 's' });
  
  $.validator.addMethod('username', function(value, element){
    return this.optional(element) || /^[a-z][a-z0-9_]+$/.test(value);
  }, 'Should use only lowercase letters, numbers, and underscore please.');
  
  $('#signup-form input[type=text]').inputHint({ using: '+kbd' });
  $('#signup-form input[type=password]').inputHint({ using: '+kbd' });
  $('#signup-form').validate({
    rules: {
      'user[email]': { remote: '/users/unique' },
      'user[login]': { rangelength: [3,100],
                       remote: '/users/unique',
                       username: true },
      'user[password]': { minlength: 4 },
      'user[password_confirmation]': { equalTo: '#user_password' }
    },
    messages: {
      'user[email]': { remote: 'Sorry, an account with this email address already exists.' },
      'user[login]': { remote: 'Sorry, username has already been taken.' }
    }
  });
  
  $('#biography').livequery(function(){
    $(this).expander({
      slicePoint: 1200,
      expandText: '<span class="small">Read more</span>',
      userCollapseText: '<span class="small">Show less</span>'
    });
  });
  
  $('#review').livequery(function(){
    $(this).expander({
      slicePoint: 450,
      expandText: '<span class="small">Read more</span>',
      userCollapseText: '<span class="small">Show less</span>'
    });
  });
  
});