//= require rails-ujs

window.init = function(){
  $('form').attr('autocomplete', 'off');

  var flash = $(".flash-message");
  setTimeout(function(){
    flash.fadeOut();
  }, 8000);
};

$(function(){
  window.init();
});
