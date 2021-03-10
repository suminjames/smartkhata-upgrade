$(document).on("ready page:load", function () {
    // payment transaction initiate payment
    if ($('.receipt_transactions.initiate_payment').length == 0) {
        return false;
    }

    let connectIpsBtn = document.querySelector('.connectIpsBtn');

    if(connectIpsBtn) {
      connectIpsBtn.addEventListener('click', function (e) {
        e.target.disabled = true;
        processPayment();
      });
    }

    function processPayment() {
        let billIds = document.querySelector('#billIds');
        let bills = billIds.value.split(' ');
        let txnAmt = document.querySelector('#txnAmt');
        let token = $("meta[name='csrf-token']").attr('content');

        var request = $.ajax({
            method: "POST",
            url: "/nchl_receipts/",
            data: {
                amount: txnAmt.value,
                bill_ids: bills,
                authenticity_token: token,
            }
        });

        request.done(function (res) {
            // todo: modal to inform that payment could not be processed

            if (res.error) {
              Swal.fire({
                icon: 'error',
                title: 'Your transaction could not be processed right now. Please try again later.',
              })
            } else {
                let connectIpsPaymentForm = document.querySelector('#connectIpsPaymentForm');

                fillData(res);
                connectIpsPaymentForm.submit();
            }
            connectIpsBtn.disabled = false;
        });

        request.fail(function () {
            // todo: modal to inform that payment could not be processed
            console.log("could not process payment");
            connectIpsBtn.disabled = false;
        });
    }

    function fillData(res) {
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

        merchantId.value = res.merchant_id;
        appId.value = res.app_id;
        appName.value = res.app_name;
        txnId.value = res.transaction_id;
        txnDate.value = res.transaction_date;
        txnCurrency.value = res.transaction_currency;
        refId.value = res.reference_id;
        remarks.value = res.remarks;
        particulars.value = res.particular;
        nchlToken.value = res.token;
    }
});