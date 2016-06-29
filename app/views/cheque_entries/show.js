var title = '.modal-title',
    loader = '.ajax-loader',
    content = '.modal-body',
    modal = '#smartkhata-modal';

//i set the title through a helper function
$(title).html('Cheque details');
$(content).html('<%= j render("show", cheque_entry: @cheque_entry) %>');
$(modal).modal();