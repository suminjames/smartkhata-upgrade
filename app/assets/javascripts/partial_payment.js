$(document).on("ready page:load", function () {
// payment transaction initiate payment
    if ($('.receipt_transactions.initiate_payment').length == 0) {
        return false;
    }

    let txnAmtField = document.querySelector('#txnAmt');
    let validAmountText = document.querySelector('#validAmountText');

    let payAmountField = document.querySelector('.payAmount');
    payAmountField.addEventListener('keyup',function (){
        validateAmount(this);
    });

    function validateAmount(amountField){
        let amount = parseFloat(amountField.value);
        let txnAmt = parseFloat(txnAmtField.value);
        let minimumTxnAmount = 10
        if (isNaN(amount) || amount < minimumTxnAmount || amount > txnAmt ){
            $('.ePayBtn').addClass('disabled');
            validAmountText.classList.remove('d-none');
        } else{
            $('.ePayBtn').removeClass('disabled');
            validAmountText.classList.add('d-none')
        }
    }

});