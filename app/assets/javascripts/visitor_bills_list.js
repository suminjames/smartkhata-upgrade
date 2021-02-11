$(document).on("ready page:load", function () {

    // visitors index page search
    if ($('#bill_list').length == 0) {
        return false;
    }

    let visitorBill = document.querySelector('#visitorBill');
    let proceedToPayBtn = document.querySelector('.proceedToPay');

    let currentUrl = window.location.href;

    if (!(localStorage.getItem('billIdsForPayment') && currentUrl.includes('page'))) {
        localStorage.setItem('billIdsForPayment', JSON.stringify([]));
    }

    if (localStorage.getItem('billIdsForPayment') && JSON.parse(localStorage.getItem('billIdsForPayment')).length > 0) {
        document.querySelectorAll("input[type='checkbox']").forEach(function (checkbox) {
            if (JSON.parse(localStorage.getItem('billIdsForPayment')).includes(checkbox.value)) {
                checkbox.checked = true
            }
        });
    }

    document.querySelectorAll("input[type='checkbox']").forEach(function (checkbox) {
        checkbox.addEventListener('click', function () {
            let billCollection = JSON.parse(localStorage.getItem('billIdsForPayment'));
            if (checkbox.checked && !billCollection.includes(checkbox.value)) {
                billCollection.push(checkbox.value);
            } else {
                removeAllElements(billCollection, checkbox.value);
            }
            localStorage.setItem('billIdsForPayment', JSON.stringify(billCollection))
        })
    });

    proceedToPayBtn.addEventListener('click', function () {
        JSON.parse(localStorage.getItem('billIdsForPayment')).forEach(function (bill) {
            var billInput = document.createElement('input');
            billInput.value = bill;
            billInput.name = "bill_ids[]";
            billInput.type = "hidden";
            visitorBill.appendChild(billInput);
        });
        localStorage.removeItem('billIdsForPayment');
    });

    function removeAllElements(array, elem) {
        var index = array.indexOf(elem);
        while (index > -1) {
            array.splice(index, 1);
            index = array.indexOf(elem);
        }
    }
});