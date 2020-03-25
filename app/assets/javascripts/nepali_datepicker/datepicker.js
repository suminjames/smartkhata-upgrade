$(function(){
    $(".nepali-datepicker").nepaliDatePicker({
        dateFormat: "%y-%m-%d",
        closeOnDateSelect: true,
    });

    $(document).on('click', '.clear-date', function(){
        $(this).prev('.nepali-datepicker').val("");
        $(this).hide();
    })
    $('.nepali-datepicker').on('ndp:date-select', function(){
        show_clear_button($(this));
    });

    $(document).on('keyup','.nepali-datepicker', function(){
        date_val = $(this).val();
        if(date_val){
            show_clear_button($(this));
        }else{
            hide_clear_button($(this));
        }
    })

    function hide_clear_button($element){
        $element.next('.clear-date').hide();
    }

    function show_clear_button($element){
        $element.next('.clear-date').show();
    }
})