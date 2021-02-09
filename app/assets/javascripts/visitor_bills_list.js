$(document).on("ready page:load", function () {

    // visitors index page search
    if ($('#bill_list').length == 0) {
        return false;
    }

    let visitorBill = document.querySelector('#visitorBill');
    let proceedToPayBtn = document.querySelector('.proceedToPay');

    let currentUrl = window.location.href;

    let billIds = localStorage.getItem('billIdsForPayment');
    if (!(billIds && currentUrl.includes('visitor_bills?page'))) {
        localStorage.setItem('billIdsForPayment', JSON.stringify([]));
    }

    if (billIds) {
        document.querySelectorAll("input[type='checkbox']").forEach(function (checkbox) {
            if (JSON.parse(billIds).includes(checkbox.value)) {
                checkbox.checked = true
            }
        });
    }

    document.querySelectorAll("input[type='checkbox']").forEach(function (checkbox) {
        checkbox.addEventListener('click', function () {
            let billCollection = JSON.parse(billIds);

            if (checkbox.checked && !billCollection.includes(checkbox.value)) {
                billCollection.push(checkbox.value);
            } else {
                removeAllElements(billCollection, checkbox.value);
            }
            localStorage.setItem('billIdsForPayment', JSON.stringify(billCollection))
        })
    });

    proceedToPayBtn.addEventListener('click', function () {
        JSON.parse(billIds).forEach(function (bill) {
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