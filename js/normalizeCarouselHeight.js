var minHeight = 200;
rescaleCarouselItems = function()
{
  var carouselItems = $("div.item");
  var i;
  var maxHeight = 0;
  var currentHeight = 0;
  for (i = 0; i < carouselItems.length; i++)
  {
    currentHeight = $(carouselItems[i]).height();
    maxHeight = Math.max(currentHeight, maxHeight);
  }
  maxHeight = Math.max(maxHeight, minHeight);
  console.log("Setting everything to height: " + maxHeight);
  for (i = 0; i < carouselItems.length; i++)
  {
    $(carouselItems[i]).height(maxHeight);
  }
}
