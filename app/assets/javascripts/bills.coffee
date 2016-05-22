# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# The following methods print and callPrint has been excerpted from https://www.sitepoint.com/load-pdf-iframe-call-print/
`jQuery(document).ready(function($) {
    // The following check makes sure the code executes only if the DOM has an element with id 'bill-full'.
    if ($('.bill-full').length > 0) {

        $("#printPDF").click(function(){
            console.log('clicked');
            print(window.location.href+".pdf");
        });

        function print(url)
        {
            console.log('print');
            var _this = this,
                iframeId = 'iframe-for-print',
                $iframe = $('iframe#iframe-for-print');
            
            $iframe.attr('src', url);
            
            $iframe.load(function() {
              callPrint(iframeId);
            });
        }

        //initiates print once content has been loaded into iframe
        function callPrint(iframeId) {
          console.log('callPrint');
          var PDF = document.getElementById(iframeId);
          PDF.focus();
          PDF.contentWindow.print();
        }
    }
});`
