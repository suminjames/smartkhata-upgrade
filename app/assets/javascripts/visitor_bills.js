$(document).on("ready page:load", function () {

// visitors index page search
  if ($('.visitors.index').length == 0) {
    return false;
  }
  var searchBtn = document.querySelector('#searchNepseBtn');
  var nepseField = document.querySelector('#nepseField');
  var waitPrompt = document.querySelector('#waitPrompt');


  nepseField.addEventListener('keyup', function (e) {
    if (e.target.value != '') {
      searchBtn.disabled = false;
    } else {
      searchBtn.disabled = true
    }
  });

  function toggleProcessingAction() {
    waitPrompt.classList.toggle('d-none');
    searchBtn.disabled = false;
  }

  function processBillSearch() {
    var request = $.ajax({
      method: "GET",
      url: "/visitor_bills/search/",
      data: {
        q: {
          nepse: nepseField.value
        }
      }
    });
    request.done(function (msg) {
      toggleProcessingAction()
      document.querySelector('#billsContent').innerHTML = msg;
    });

    request.fail(function () {
      console.log("could not find record");
      toggleProcessingAction()
    });
  }

  $(searchBtn).click((e) => {
    waitPrompt.classList.toggle('d-none');
    searchBtn.disabled = true;
    processBillSearch();
  });

});