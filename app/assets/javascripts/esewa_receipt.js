$(document).on("ready page:load", function () {
    // payment transaction initiate payment
    if ($('.receipt_transactions.initiate_payment').length == 0) {
        return false;
    }

    let submitPaymentBtn = document.querySelector('#esewaSubmit');
    let amountField = document.querySelector('#amountField');
    let validAmountText = document.querySelector('#validAmountText');

    amountField.addEventListener('change', function (e) {
      if(true){ //check amount to pay validation
        validAmountText.style.visibility  = 'visible';
      } else {
        validAmountText.style.visibility = 'hidden';
      }
    });

    if(submitPaymentBtn) {
      submitPaymentBtn.addEventListener('click', function (e) {
        e.target.disabled = true;
        processPayment();
      });
    }

    function fillData(res) {
        let successUrl = document.querySelector('input[name="su"]');
        let failureUrl = document.querySelector('input[name="fu"]');
        let securityCode = document.querySelector('input[name="scd"]');
        let productId = document.querySelector('input[name="pid"]');

        successUrl.setAttribute('value', res.payment.success_url);
        failureUrl.setAttribute('value', res.payment.failure_url);
        securityCode.setAttribute('value', res.security_code);
        productId.setAttribute('value', res.product_id);
    }

    function getPayload() {
        let amount = document.querySelector('input[name="amt"]');
        let serviceCharge = document.querySelector('input[name="psc"]');
        let deliveryCharge = document.querySelector('input[name="pdc"]');
        let taxAmount = document.querySelector('input[name="txAmt"]');
        let totalAmount = document.querySelector('input[name="tAmt"]');
        let token = $("meta[name='csrf-token']").attr('content');
        let billIds = document.querySelector('#billIds');
        let bills = billIds.value.split(' ');

        return ({
            amount: parseInt(amount.value),
            bill_ids: bills,
            service_charge: parseInt(serviceCharge.value),
            delivery_charge: parseInt(deliveryCharge.value),
            tax_amount: parseInt(taxAmount.value),
            total_amount: parseInt(totalAmount.value),
            authenticity_token: token,
        })
    }

    function processPayment() {
        let paymentForm = document.querySelector('#esewaPaymentForm');

        let request = $.ajax({
            method: "POST",
            url: "/esewa_receipts/",
            data: getPayload(),
        });

        request.done(function (res) {
            if (res.error) {
              Swal.fire({
                icon: 'error',
                title: 'Your transaction could not be processed right now. Please try again later.',
              })
            } else {
                fillData(res);
                paymentForm.submit();
            }
            submitPaymentBtn.disabled = false;
        });

        request.fail(function () {
            // todo: modal to inform that payment could not be processed
            console.log("could not process payment");
            submitPaymentBtn.disabled = false;
        });

    }

});