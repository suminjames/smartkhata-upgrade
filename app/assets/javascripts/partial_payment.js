$(document).on("ready page:load", function () {
// payment transaction initiate payment
    if ($('.receipt_transactions.initiate_payment').length == 0) {
        return false;
    }

    let txnAmtField = document.querySelector('#txnAmt');
    let connectIpsBtn = document.querySelector('.connectIpsBtn');

    let payAmountField = document.querySelector('.payAmount');
    payAmountField.addEventListener('keyup',function (){
        validateAmount(this);
    });

    function validateAmount(amountField){
        let amount = parseInt(amountField.value);
        let txnAmt = parseInt(txnAmtField.value);
        let minimumTxnAmount = 3
        if (amount < minimumTxnAmount || amount > txnAmt ){
            connectIpsBtn.disabled = true;
        } else{
            connectIpsBtn.disabled = false;
        }
    }

});