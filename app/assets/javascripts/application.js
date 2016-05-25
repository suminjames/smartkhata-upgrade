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
    bill_id = this.id.split("-")[1];
    loadAndPrint( "/bills/"+ bill_id + '.pdf', 'iframe-for-bill-pdf-print');
});

$(document).on("click", ".btnPrintVoucherPDF", function(event) {
    console.log("print voucher");
    voucher_id = this.id.split("-")[1];
    loadAndPrint( "/vouchers/"+ voucher_id+ '.pdf', 'iframe-for-voucher-pdf-print');
});

$(document).on("click", ".btnPrintChequeEntryPDF", function(event) {
    console.log("print voucher");
    cheque_entry_id = this.id.split("-")[1];
    loadAndPrint( "/cheque_entries/"+ cheque_entry_id + '.pdf', 'iframe-for-cheque-entry-pdf-print');
});

// The following methods print and callPrint has been excerpted from https://www.sitepoint.com/load-pdf-iframe-call-print/
function loadAndPrint(url, iframeId) {
    console.log("load and print");
    var _this = this,
        $iframe = $('iframe#'+iframeId)

    $iframe.attr('src', url);

    $iframe.load(function() {
        callPrint(iframeId);
    });
}

//initiates print once content has been loaded into iframe
function callPrint(iframeId) {
    console.log("call print");
    var PDF = document.getElementById(iframeId);
    PDF.focus();
    PDF.contentWindow.print();
}
