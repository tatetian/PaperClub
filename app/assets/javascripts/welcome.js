$(function( ){
  function onResize() {
    // Adjust the minimum height of content
    var $content = $('.p-page-content');
    $content.css('min-height' , $(window).height() - 48);
    // Adjust the slides with
    var imgWidth = 767;//$content.width() - 255 * 2,
        imgHeight = 413;// * imgWidth / 767, 
        H = imgHeight + 71 + 48 ;
    $("#slides").width(imgWidth);
    $(".slide").height(H).width(imgWidth);
    $(".slide > img").height(imgHeight);
    $(".slide > img").width(imgWidth);
    $(".slide > .caption").width(imgWidth);
    $(".i-focus-list").css("margin-left", 
                        ($content.width()-imgWidth)/2);
  }
  $(window).resize(onResize);
  onResize();

  $('#slides').slides({
    play: 3500,
    effect: 'fade, fade',
    pagination: true,
    preload: true,
    preloadImage: "assets/loading.gif"
  });

  $('input, textarea').placeholder();
  
  var validate = {
    email: function(email){
      var testEmail = /^.+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,3}|[0-9]{1,3})(\]?)$/;
      return testEmail.test(email);
    },
    password: function (pwd){
      var testPWD = /^(?![a-z]+$)(?!\d+$)[a-z0-9]{8,20}$/i;
      return testPWD.test(pwd);
    },
    fullname: function() {
      return true;
    } 
  };
  
  $("input").keyup(function(){
    $(this).data("edited",true);
  }).focus(function() {
    $(this).css("border-bottom","1px solid #51f037");
  }).blur(function(){
    var $t = $(this),
         edited = $t.data("edited"),
         name = $t.attr("id").slice(5),
         value = $t.val();
  
    if(edited && !validate[name](value)) {
      $(this).css("border-bottom","1px solid #f03737");
    }
    else if(!edited){
      $(this).css("border-bottom","1px solid rgb(204, 204, 204)");
    }
  });
});
