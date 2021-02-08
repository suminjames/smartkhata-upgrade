$(document).on("ready page:load", function () {
// payment transaction initiate payment
//     if ($('.payment_transactions.initiate_payment').length == 0) {
//         return false;
//     }

    // let billIds = document.querySelector('#billIds');

    let txnAmt = document.querySelector('#txnAmt');
    let connectIpsBtn = document.querySelector('.connectIpsBtn');
    // let bills = billIds.value.split(' ');
    let nchlToken = document.querySelector('#nchlToken');
    let connectIpsPaymentForm = document.querySelector('#connectIpsPaymentForm');
    connectIpsBtn.addEventListener('click', function (e) {
        e.target.disabled = true;
        processPayment();
    });

    function processPayment() {
        let token = $("meta[name='csrf-token']").attr('content');
        var request = $.ajax({
            method: "POST",
            url: "/nchl_payments/",
            data: {
                txnAmt: parseInt(txnAmt.value),
                // bill_ids: bills,
                authenticity_token: token,
            }
        });
        request.done(function (res) {
            nchlToken.value = res.signed_token;
            connectIpsPaymentForm.submit();
            connectIpsBtn.disabled = false;
        });
        request.fail(function () {
            // todo: modal to inform that payment could not be processed
            console.log("could not process payment");
            connectIpsBtn.disabled = false;
        });
    }
});