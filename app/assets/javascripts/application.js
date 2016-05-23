// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-hotkeys
//= require turbolinks
//= require bootstrap-sprockets
//= require bootstrap-combobox.js
//= require smart_listing
//= require layout.min.js
//= require_tree .
$(document).on('click', '.yamm .dropdown-menu', function(e) {
  e.stopPropagation()
});


function printElement(elem) {
    var domClone = elem.cloneNode(true);

    var $printSection = document.getElementById('printSection');
    if (!$printSection) {
        $printSection = document.createElement("div");
        $printSection.id = "printSection";
        document.body.appendChild($printSection);
    }
    $printSection.innerHTML = "";
    $printSection.appendChild(domClone);
}

$(document).on("click", "#btnPrint", function(event) {
    // printElement(document.getElementById("printThis"));
    printElement($('.printThis')[0]);
    window.print();
});


$(document).on("click", ".btnPrintBillPDF", function(event) {
    console.log("clicked");
    bill_id = this.id.split("-")[1];
    print( "/bills/"+ bill_id + '.pdf');
});

// The following methods print and callPrint has been excerpted from https://www.sitepoint.com/load-pdf-iframe-call-print/
function print(url) {
    console.log("print");
    var _this = this,
        iframeId = 'iframe-for-bill-pdf-print',
        $iframe = $('iframe#iframe-for-bill-pdf-print')

    $iframe.attr('src', url);

    $iframe.load(function() {
        callPrint(iframeId);
    });
}

//initiates print once content has been loaded into iframe
function callPrint(iframeId) {
    console.log("callPrint");
    var PDF = document.getElementById(iframeId);
    PDF.focus();
    PDF.contentWindow.print();
}
