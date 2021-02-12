$(document).on("ready page:load", function () {
// payment transaction initiate payment
    if ($('.receipt_transactions.initiate_payment').length == 0) {
        return false;
    }

    let billIds = document.querySelector('#billIds');
    let txnAmt = document.querySelector('#txnAmt');
    let nchlToken = document.querySelector('#nchlToken');
    let merchantId = document.querySelector("#merchantId");
    let appId = document.querySelector("#appId");
    let appName = document.querySelector("#appName");
    let txnId = document.querySelector("#txnId");
    let txnDate = document.querySelector("#txnDate");
    let txnCurrency = document.querySelector("#txnCurrency");
    let refId = document.querySelector("#refId");
    let remarks = document.querySelector("#remarks");
    let particulars = document.querySelector("#particulars");

    let connectIpsPaymentForm = document.querySelector('#connectIpsPaymentForm');
    let connectIpsBtn = document.querySelector('.connectIpsBtn');

    let bills = billIds.value.split(' ');

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
                amount: txnAmt.value,
                bill_ids: bills,
                authenticity_token: token,
            }
        });
        request.done(function (res) {
            // todo: modal to inform that payment could not be processed

            fillData(res);
            connectIpsPaymentForm.submit();
            connectIpsBtn.disabled = false;
        });
        request.fail(function () {
            // todo: modal to inform that payment could not be processed
            console.log("could not process payment");
            connectIpsBtn.disabled = false;
        });
    }

    function fillData(res) {
        merchantId.value = res.merchant_id;
        appId.value = res.app_id;
        appName.value = res.app_name;
        txnId.value = res.txn_id;
        txnDate.value = res.txn_date;
        txnCurrency.value = res.txn_currency;
        refId.value = res.ref_id;
        remarks.value = res.remarks;
        particulars.value = res.particulars;
        nchlToken.value = res.signed_token;
    }
});