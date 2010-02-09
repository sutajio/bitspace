$(function(){
  
  $('.field input').inputHint({ using: '+kbd' });
  
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
  
});