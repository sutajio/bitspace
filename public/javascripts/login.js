$(function(){
  
  $('.field input').inputHint({ using: '+kbd' });
  $('.field textarea').inputHint({ using: '+kbd' });
  
  $('#reset-password-form').validate({
    rules: { password: { required: true, minlength: 4 } }
  });
  
  $.validator.addMethod('username', function(value, element){
    return this.optional(element) || /^[a-z][a-z0-9_]+$/.test(value);
  }, 'Should use only lowercase letters, numbers, and underscore please.');
  
  $('#account-credentials-form').validate({
    rules: {
      'user[login]': { rangelength: [3,100],
                       remote: '/users/unique',
                       username: true },
      'user[password]': { minlength: 4 }
    },
    messages: {
      'user[login]': { remote: 'Sorry, username has already been taken.' }
    }
  });
  
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
  
  $('.segmented input[type=radio]').change(function(e){
    $(this).siblings('label').removeClass('checked');
    if($(this).attr('checked')) {
      $(this).next('label').addClass('checked');
    } else {
      $(this).next('label').removeClass('checked');
    }
  });
  
  $('#new-release-form').validate();
  
});