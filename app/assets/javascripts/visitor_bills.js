$(document).on("ready page:load", function() {

// visitors index page search
  if ($('.visitors.index').length == 0) {
    return false;
  }
  console.log('visitors bills index')
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

  $(searchBtn).click((e) => {
    waitPrompt.classList.toggle('d-none');
    searchBtn.disabled = true;
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
      document.querySelector('#billsContent').innerHTML = msg;
      waitPrompt.classList.toggle('d-none');
      searchBtn.disabled = false;
    });

    request.fail(function () {
      console.log("could not find record");
      waitPrompt.classList.toggle('d-none');
      searchBtn.disabled = false;
    })

  });
});