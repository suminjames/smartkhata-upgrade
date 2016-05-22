# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# The following methods print and callPrint has been excerpted from https://www.sitepoint.com/load-pdf-iframe-call-print/
`jQuery(document).ready(function($) {
    // The following check makes sure the code executes only if the DOM has an element with id 'bill-full'.
    if ($('.bill-full').length > 0) {

        $(".btnPrintPDF").click(function(){
            console.log("clicked")
            bill_id = this.id.split("-")[1]
            print( bill_id + '.pdf');
        });

        function print(url) {
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
          var PDF = document.getElementById(iframeId);
          PDF.focus();
          PDF.contentWindow.print();
        }
    }
});`
