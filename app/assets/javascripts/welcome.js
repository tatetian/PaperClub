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
    preload: true
  });
});
