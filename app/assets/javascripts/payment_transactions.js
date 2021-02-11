$(document).on("ready page:load", function () {

// payment transaction initiate payment
  if ($('.payment_transactions.initiate_payment').length == 0) {
    return false;
  }

  let billIds = document.querySelector('#billIds');
  let amount = document.querySelector('input[name="amt"]');
  let serviceCharge = document.querySelector('input[name="psc"]');
  let deliveryCharge = document.querySelector('input[name="pdc"]');
  let taxAmount = document.querySelector('input[name="txAmt"]');
  let totalAmount = document.querySelector('input[name="tAmt"]');
  let successUrl = document.querySelector('input[name="su"]');
  let failureUrl = document.querySelector('input[name="fu"]');
  let securityCode = document.querySelector('input[name="scd"]');
  let productId = document.querySelector('input[name="pid"]');
  let submitPaymentBtn = document.querySelector('#esewaSubmit');

  let bills = billIds.value.split(' ');

  let paymentForm = document.querySelector('#esewaPaymentForm');
  let token = $("meta[name='csrf-token']").attr('content');

  submitPaymentBtn.addEventListener('click', function (e) {
    e.target.disabled = true;
    processPayment();
  });

  function fillData(res) {
    successUrl.setAttribute('value', res.payment.success_url);
    failureUrl.setAttribute('value', res.payment.failure_url);
    securityCode.setAttribute('value', res.security_code);
    productId.setAttribute('value', res.payment.id);
  }

  function getPayload(){
    return({
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

    var request = $.ajax({
      method: "POST",
      url: "/esewa_payments/",
      data: getPayload(),
    });

    request.done(function (res) {
      fillData(res);
      paymentForm.submit();
      submitPaymentBtn.disabled = false;
    });

    request.fail(function () {
      // todo: modal to inform that payment could not be processed
      console.log("could not process payment");
      submitPaymentBtn.disabled = false;
    });

  }

});