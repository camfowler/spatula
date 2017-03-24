var system = require('system');
var paprika_token = process.env.PAPRIKA_TOKEN;
if (system.args.length === 1) {
  console.log('Please pass a URL to fetch');
  phantom.exit();
}
if (paprika_token.length === 16) {
  console.log('Environment variable PAPRIKA_TOKEN not set or not 16 chars');
  phantom.exit();
}

var url = system.args[1];
// var url = 'http://chelseawinter.co.nz/thai-chicken-noodle-salad/';
console.log('Scraping a new recipe: ' + url);

var page = require('webpage').create();

page.viewportSize = {
  width: 1920,
  height: 1080
};

page.open(url, function (status) {
  // Wait for page to fully load images etc. This could be done better, see:
  //
  //   https://github.com/ariya/phantomjs/issues/13717
  //
  setTimeout(function() {

    // Include the paprica javascript, which runs itself automatically.
    page.includeJs("http://www.paprikaapp.com/bookmarklet/v1/?token=" + paprika_token + "&timestamp=" + (new Date().getTime()), function() {

      // Wait for the included javascript to finish running. Ideally the
      // papricka function to trigger the code would be called by phantom, so
      // phantom could wait until finishing. This may not matter as we probably
      // wont have a high volume of recipes to scrape, so taking 2+ minutes per
      // call even is fine.
      setTimeout(function() {
        console.log('Done');
        phantom.exit();
      }, 10000);

    });

  }, 10000);

});
