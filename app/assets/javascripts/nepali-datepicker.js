var calendarFunctions = {};
! function($) {
    var calendarData = {
            bsMonths: ["Baisakh", "Jestha", "Asadh", "Shrawan", "Bhadra", "Asoj", "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra"],
            bsDays: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
            nepaliNumbers: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
            bsMonthUpperDays: [
                [30, 31],
                [31, 32],
                [31, 32],
                [31, 32],
                [31, 32],
                [30, 31],
                [29, 30],
                [29, 30],
                [29, 30],
                [29, 30],
                [29, 30],
                [30, 31]
            ],
            extractedBsMonthData: [
                [0, 1, 1, 22, 1, 3, 1, 1, 1, 3, 1, 22, 1, 3, 1, 3, 1, 22, 1, 3, 1, 19, 1, 3, 1, 1, 3, 1, 2, 2, 1, 3, 1],
                [1, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 2, 2, 2, 2, 2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 3, 1, 1, 2],
                [0, 1, 2, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 3, 1, 1, 2],
                [1, 2, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 1, 3, 1, 2, 2, 2, 1, 2],
                [59, 1, 26, 1, 28, 1, 2, 1, 12],
                [0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 1, 1, 2, 2, 1, 3, 1, 2, 1, 2],
                [0, 12, 1, 3, 1, 3, 1, 5, 1, 11, 1, 3, 1, 3, 1, 18, 1, 3, 1, 3, 1, 18, 1, 3, 1, 3, 1, 27, 1, 2],
                [1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 3, 1, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 15, 2, 4],
                [0, 1, 2, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 2, 2, 2, 15, 2, 4],
                [1, 1, 3, 1, 3, 1, 14, 1, 3, 1, 1, 1, 3, 1, 14, 1, 3, 1, 3, 1, 3, 1, 18, 1, 3, 1, 3, 1, 3, 1, 14, 1, 3, 15, 1, 2, 1, 1],
                [0, 1, 1, 3, 1, 3, 1, 10, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 10, 1, 3, 1, 3, 1, 3, 1, 3, 1, 14, 1, 3, 1, 3, 1, 3, 1, 3, 1, 10, 1, 20, 1, 1, 1],
                [1, 2, 2, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 3, 1, 20, 3]
            ],
            minBsYear: 1970,
            maxBsYear: 2100,
            minAdDateEqBsDate: {
                ad: {
                    year: 1913,
                    month: 3,
                    date: 13
                },
                bs: {
                    year: 1970,
                    month: 1,
                    date: 1
                }
            }
        },
        validationFunctions = {
            validateRequiredParameters: function(requiredParameters) {
                $.each(requiredParameters, function(key, value) {
                    if ("undefined" == typeof value || null === value) throw new ReferenceError("Missing required parameters: " + Object.keys(requiredParameters).join(", "))
                })
            },
            validateBsYear: function(bsYear) {
                if ("number" != typeof bsYear || null === bsYear) throw new TypeError("Invalid parameter bsYear value");
                if (bsYear < calendarData.minBsYear || bsYear > calendarData.maxBsYear) throw new RangeError("Parameter bsYear value should be in range of " + calendarData.minBsYear + " to " + calendarData.maxBsYear)
            },
            validateAdYear: function(adYear) {
                if ("number" != typeof adYear || null === adYear) throw new TypeError("Invalid parameter adYear value");
                if (adYear < calendarData.minBsYear - 57 || adYear > calendarData.maxBsYear - 57) throw new RangeError("Parameter adYear value should be in range of " + (calendarData.minBsYear - 57) + " to " + (calendarData.maxBsYear - 57))
            },
            validateBsMonth: function(bsMonth) {
                if ("number" != typeof bsMonth || null === bsMonth) throw new TypeError("Invalid parameter bsMonth value");
                if (bsMonth < 1 || bsMonth > 12) throw new RangeError("Parameter bsMonth value should be in range of 1 to 12")
            },
            validateAdMonth: function(adMonth) {
                if ("number" != typeof adMonth || null === adMonth) throw new TypeError("Invalid parameter adMonth value");
                if (adMonth < 1 || adMonth > 12) throw new RangeError("Parameter adMonth value should be in range of 1 to 12")
            },
            validateBsDate: function(bsDate) {
                if ("number" != typeof bsDate || null === bsDate) throw new TypeError("Invalid parameter bsDate value");
                if (bsDate < 1 || bsDate > 32) throw new RangeError("Parameter bsDate value should be in range of 1 to 32")
            },
            validateAdDate: function(adDate) {
                if ("number" != typeof adDate || null === adDate) throw new TypeError("Invalid parameter adDate value");
                if (adDate < 1 || adDate > 31) throw new RangeError("Parameter adDate value should be in range of 1 to 31")
            },
            validatePositiveNumber: function(numberParameters) {
                $.each(numberParameters, function(key, value) {
                    if ("number" != typeof value || null === value || value < 0) throw new ReferenceError("Invalid parameters: " + Object.keys(numberParameters).join(", "));
                    if ("yearDiff" === key && value > calendarData.maxBsYear - calendarData.minBsYear + 1) throw new RangeError("Parameter yearDiff value should be in range of 0 to " + (calendarData.maxBsYear - calendarData.minBsYear + 1))
                })
            }
        };
    $.extend(calendarFunctions, {
        getNepaliNumber: function(number) {
            if ("undefined" == typeof number) throw new Error("Parameter number is required");
            if ("number" != typeof number || number < 0) throw new Error("Number should be positive integer");
            var prefixNum = Math.floor(number / 10),
                suffixNum = number % 10;
            return 0 !== prefixNum ? calendarFunctions.getNepaliNumber(prefixNum) + calendarData.nepaliNumbers[suffixNum] : calendarData.nepaliNumbers[suffixNum]
        },
        getNumberByNepaliNumber: function(nepaliNumber) {
            if ("undefined" == typeof nepaliNumber) throw new Error("Parameter nepaliNumber is required");
            if ("string" != typeof nepaliNumber) throw new Error("Parameter nepaliNumber should be in string");
            for (var number = 0, i = 0; i < nepaliNumber.length; i++) {
                var numIndex = calendarData.nepaliNumbers.indexOf(nepaliNumber.charAt(i));
                if (numIndex === -1) throw new Error("Invalid nepali number");
                number = 10 * number + numIndex
            }
            return number
        },
        getBsMonthInfoByBsDate: function(bsYear, bsMonth, bsDate, dateFormatPattern) {
            if (validationFunctions.validateRequiredParameters({
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDate: bsDate
            }), validationFunctions.validateBsYear(bsYear), validationFunctions.validateBsMonth(bsMonth), validationFunctions.validateBsDate(bsDate), null === dateFormatPattern) dateFormatPattern = "%D, %M %d, %y";
            else if ("string" != typeof dateFormatPattern) throw new TypeError("Invalid parameter dateFormatPattern value");
            var daysNumFromMinBsYear = calendarFunctions.getTotalDaysNumFromMinBsYear(bsYear, bsMonth, bsDate),
                adDate = new Date(calendarData.minAdDateEqBsDate.ad.year, calendarData.minAdDateEqBsDate.ad.month, calendarData.minAdDateEqBsDate.ad.date - 1);
            adDate.setDate(adDate.getDate() + daysNumFromMinBsYear);
            var bsMonthFirstAdDate = calendarFunctions.getAdDateByBsDate(bsYear, bsMonth, 1),
                bsMonthDays = calendarFunctions.getBsMonthDays(bsYear, bsMonth);
            bsDate = bsDate > bsMonthDays ? bsMonthDays : bsDate;
            var eqAdDate = calendarFunctions.getAdDateByBsDate(bsYear, bsMonth, bsDate),
                weekDay = eqAdDate.getDay() + 1,
                formattedDate = calendarFunctions.bsDateFormat(dateFormatPattern, bsYear, bsMonth, bsDate);
            return {
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDate: bsDate,
                weekDay: weekDay,
                formattedDate: formattedDate,
                adDate: eqAdDate,
                bsMonthFirstAdDate: bsMonthFirstAdDate,
                bsMonthDays: bsMonthDays
            }
        },
        getAdDateByBsDate: function(bsYear, bsMonth, bsDate) {
            validationFunctions.validateRequiredParameters({
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDate: bsDate
            }), validationFunctions.validateBsYear(bsYear), validationFunctions.validateBsMonth(bsMonth), validationFunctions.validateBsDate(bsDate);
            var daysNumFromMinBsYear = calendarFunctions.getTotalDaysNumFromMinBsYear(bsYear, bsMonth, bsDate),
                adDate = new Date(calendarData.minAdDateEqBsDate.ad.year, calendarData.minAdDateEqBsDate.ad.month, calendarData.minAdDateEqBsDate.ad.date - 1);
            return adDate.setDate(adDate.getDate() + daysNumFromMinBsYear), adDate
        },
        getTotalDaysNumFromMinBsYear: function(bsYear, bsMonth, bsDate) {
            if (validationFunctions.validateRequiredParameters({
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDate: bsDate
            }), validationFunctions.validateBsYear(bsYear), validationFunctions.validateBsMonth(bsMonth), validationFunctions.validateBsDate(bsDate), bsYear < calendarData.minBsYear || bsYear > calendarData.maxBsYear) return null;
            for (var daysNumFromMinBsYear = 0, diffYears = bsYear - calendarData.minBsYear, month = 1; month <= 12; month++) daysNumFromMinBsYear += month < bsMonth ? calendarFunctions.getMonthDaysNumFormMinBsYear(month, diffYears + 1) : calendarFunctions.getMonthDaysNumFormMinBsYear(month, diffYears);
            return daysNumFromMinBsYear += bsYear > 2085 && bsYear < 2088 ? bsDate - 2 : 2085 === bsYear && bsMonth > 5 ? bsDate - 2 : bsYear > 2088 ? bsDate - 4 : 2088 === bsYear && bsMonth > 5 ? bsDate - 4 : bsDate
        },
        getMonthDaysNumFormMinBsYear: function(bsMonth, yearDiff) {
            validationFunctions.validateRequiredParameters({
                bsMonth: bsMonth,
                yearDiff: yearDiff
            }), validationFunctions.validateBsMonth(bsMonth), validationFunctions.validatePositiveNumber({
                yearDiff: yearDiff
            });
            var yearCount = 0,
                monthDaysFromMinBsYear = 0;
            if (0 === yearDiff) return 0;
            for (var bsMonthData = calendarData.extractedBsMonthData[bsMonth - 1], i = 0; i < bsMonthData.length; i++)
                if (0 !== bsMonthData[i]) {
                    var bsMonthUpperDaysIndex = i % 2;
                    if (!(yearDiff > yearCount + bsMonthData[i])) {
                        monthDaysFromMinBsYear += calendarData.bsMonthUpperDays[bsMonth - 1][bsMonthUpperDaysIndex] * (yearDiff - yearCount), yearCount = yearDiff - yearCount;
                        break
                    }
                    yearCount += bsMonthData[i], monthDaysFromMinBsYear += calendarData.bsMonthUpperDays[bsMonth - 1][bsMonthUpperDaysIndex] * bsMonthData[i]
                }
            return monthDaysFromMinBsYear
        },
        getBsMonthDays: function(bsYear, bsMonth) {
            validationFunctions.validateRequiredParameters({
                bsYear: bsYear,
                bsMonth: bsMonth
            }), validationFunctions.validateBsYear(bsYear), validationFunctions.validateBsMonth(bsMonth);
            for (var yearCount = 0, totalYears = bsYear + 1 - calendarData.minBsYear, bsMonthData = calendarData.extractedBsMonthData[bsMonth - 1], i = 0; i < bsMonthData.length; i++)
                if (0 !== bsMonthData[i]) {
                    var bsMonthUpperDaysIndex = i % 2;
                    if (yearCount += bsMonthData[i], totalYears <= yearCount) return 2085 === bsYear && 5 === bsMonth || 2088 === bsYear && 5 === bsMonth ? calendarData.bsMonthUpperDays[bsMonth - 1][bsMonthUpperDaysIndex] - 2 : calendarData.bsMonthUpperDays[bsMonth - 1][bsMonthUpperDaysIndex]
                }
            return null
        },
        getBsDateByAdDate: function(adYear, adMonth, adDate) {
            validationFunctions.validateRequiredParameters({
                adYear: adYear,
                adMonth: adMonth,
                adDate: adDate
            }), validationFunctions.validateAdYear(adYear), validationFunctions.validateAdMonth(adMonth), validationFunctions.validateAdDate(adDate);
            var bsYear = adYear + 57,
                bsMonth = (adMonth + 9) % 12,
                bsDate = 1;
            if (adMonth < 4) bsYear -= 1;
            else if (4 === adMonth) {
                var bsYearFirstAdDate = calendarFunctions.getAdDateByBsDate(bsYear, 1, 1);
                adDate < bsYearFirstAdDate.getDate() && (bsYear -= 1)
            }
            var bsMonthFirstAdDate = calendarFunctions.getAdDateByBsDate(bsYear, bsMonth, 1);
            if (adDate >= 1 && adDate < bsMonthFirstAdDate.getDate()) {
                bsMonth = 1 !== bsMonth ? bsMonth - 1 : 12;
                var bsMonthDays = calendarFunctions.getBsMonthDays(bsYear, bsMonth);
                bsDate = bsMonthDays - (bsMonthFirstAdDate.getDate() - adDate) + 1
            } else bsDate = adDate - bsMonthFirstAdDate.getDate() + 1;
            return {
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDate: bsDate
            }
        },
        getBsYearByAdDate: function(adYear, adMonth, adDate) {
            validationFunctions.validateRequiredParameters({
                adYear: adYear,
                adMonth: adMonth,
                adDate: adDate
            }), validationFunctions.validateAdYear(adYear), validationFunctions.validateAdMonth(adMonth), validationFunctions.validateAdDate(adDate);
            var bsDate = calendarFunctions.getBsDateByAdDate(adYear, adMonth, adDate);
            return bsDate.bsYear
        },
        getBsMonthByAdDate: function(adYear, adMonth, adDate) {
            validationFunctions.validateRequiredParameters({
                adYear: adYear,
                adMonth: adMonth,
                adDate: adDate
            }), validationFunctions.validateAdYear(adYear), validationFunctions.validateAdMonth(adMonth), validationFunctions.validateAdDate(adDate);
            var bsDate = calendarFunctions.getBsDateByAdDate(adYear, adMonth, adDate);
            return bsDate.bsMonth
        },
        bsDateFormat: function(dateFormatPattern, bsYear, bsMonth, bsDate) {
            validationFunctions.validateRequiredParameters({
                dateFormatPattern: dateFormatPattern,
                bsYear: bsYear,
                bsMonth: bsMonth,
                bsDate: bsDate
            }), validationFunctions.validateBsYear(bsYear), validationFunctions.validateBsMonth(bsMonth), validationFunctions.validateBsDate(bsDate);
            var eqAdDate = calendarFunctions.getAdDateByBsDate(bsYear, bsMonth, bsDate),
                weekDay = eqAdDate.getDay() + 1,
                formattedDate = dateFormatPattern;
            return formattedDate = formattedDate.replace(/%d/g, calendarFunctions.getNepaliNumber(bsDate)), formattedDate = formattedDate.replace(/%y/g, calendarFunctions.getNepaliNumber(bsYear)), formattedDate = formattedDate.replace(/%m/g, calendarFunctions.getNepaliNumber(bsMonth)), formattedDate = formattedDate.replace(/%M/g, calendarData.bsMonths[bsMonth - 1]), formattedDate = formattedDate.replace(/%D/g, calendarData.bsDays[weekDay - 1])
        },
        parseFormattedBsDate: function(dateFormat, dateFormattedText) {
            validationFunctions.validateRequiredParameters({
                dateFormat: dateFormat,
                dateFormattedText: dateFormattedText
            });
            for (var diffTextNum = 0, extractedFormattedBsDate = {
                bsYear: null,
                bsMonth: null,
                bsDate: null,
                bsDay: null
            }, i = 0; i < dateFormat.length; i++)
                if ("%" === dateFormat.charAt(i)) {
                    var valueOf = dateFormat.substring(i, i + 2),
                        endChar = dateFormat.charAt(i + 2),
                        tempText = dateFormattedText.substring(i + diffTextNum),
                        endIndex = "" !== endChar ? tempText.indexOf(endChar) : tempText.length,
                        value = tempText.substring(0, endIndex);
                    "%y" === valueOf ? (extractedFormattedBsDate.bsYear = calendarFunctions.getNumberByNepaliNumber(value), diffTextNum += value.length - 2) : "%d" === valueOf ? (extractedFormattedBsDate.bsDate = calendarFunctions.getNumberByNepaliNumber(value), diffTextNum += value.length - 2) : "%D" === valueOf ? (extractedFormattedBsDate.bsDay = calendarData.bsDays.indexOf(value) + 1, diffTextNum += value.length - 2) : "%m" === valueOf ? (extractedFormattedBsDate.bsMonth = calendarFunctions.getNumberByNepaliNumber(value), diffTextNum += value.length - 2) : "%M" === valueOf && (extractedFormattedBsDate.bsMonth = calendarData.bsMonths.indexOf(value) + 1, diffTextNum += value.length - 2)
                }
            if (!extractedFormattedBsDate.bsDay) {
                var eqAdDate = calendarFunctions.getAdDateByBsDate(extractedFormattedBsDate.bsYear, extractedFormattedBsDate.bsMonth, extractedFormattedBsDate.bsDate);
                extractedFormattedBsDate.bsDay = eqAdDate.getDay() + 1
            }
            return extractedFormattedBsDate
        }
    }), $.fn.nepaliDatePicker = function(options) {
        var datePickerPlugin = {
            options: $.extend({
                dateFormat: "%D, %M %d, %y",
                closeOnDateSelect: !0,
                defaultDate: "",
                minDate: null,
                maxDate: null,
                yearStart: calendarData.minBsYear,
                yearEnd: calendarData.maxBsYear
            }, options),
            init: function($element) {
               // $element.prop("readonly", !0);
                var $nepaliDatePicker = $('<div class="nepali-date-picker">');
                $("body").append($nepaliDatePicker), "" !== $element.val() ? datePickerPlugin.renderFormattedSpecificDateCalendar($nepaliDatePicker, datePickerPlugin.options.dateFormat, $element.val()) : datePickerPlugin.renderCurrentMonthCalendar($nepaliDatePicker), datePickerPlugin.addEventHandler($element, $nepaliDatePicker), datePickerPlugin.addCommonEventHandler($nepaliDatePicker)
            },
            addCommonEventHandler: function() {
                var $datePickerWrapper = $(".nepali-date-picker");
                $(document).click(function(event) {
                    var $targetElement = $(event.target);
                    $targetElement.is($(".nepali-date-picker")) || ($datePickerWrapper.hide(), $datePickerWrapper.find(".drop-down-content").hide())
                })
            },
            addEventHandler: function($element, $nepaliDatePicker) {
                $element.click(function() {
                    if ($(".nepali-date-picker").is(":visible")) return void $(".nepali-date-picker").hide();
                    var inputFieldPosition = $(this).offset();
                    return $nepaliDatePicker.css({
                        top: inputFieldPosition.top + $(this).outerHeight(!0),
                        left: inputFieldPosition.left
                    }), $nepaliDatePicker.show(), datePickerPlugin.eventFire($element, $nepaliDatePicker, "show"), !1
                }), $nepaliDatePicker.on("click", ".next-btn", function(event) {
                    event.preventDefault();
                    var preCalendarData = {
                        bsYear: $nepaliDatePicker.data().bsYear,
                        bsMonth: $nepaliDatePicker.data().bsMonth,
                        bsDate: $nepaliDatePicker.data().bsDate
                    };
                    return datePickerPlugin.renderNextMonthCalendar($nepaliDatePicker), datePickerPlugin.triggerChangeEvent($element, $nepaliDatePicker, preCalendarData), $nepaliDatePicker.show(), !1
                }), $nepaliDatePicker.on("click", ".prev-btn", function(event) {
                    event.preventDefault();
                    var preCalendarData = {
                        bsYear: $nepaliDatePicker.data().bsYear,
                        bsMonth: $nepaliDatePicker.data().bsMonth,
                        bsDate: $nepaliDatePicker.data().bsDate
                    };
                    datePickerPlugin.renderPreviousMonthCalendar($nepaliDatePicker);
                    $nepaliDatePicker.data();
                    return datePickerPlugin.triggerChangeEvent($element, $nepaliDatePicker, preCalendarData), $nepaliDatePicker.show(), !1
                }), $nepaliDatePicker.on("click", ".today-btn", function(event) {
                    event.preventDefault();
                    var preCalendarData = {
                        bsYear: $nepaliDatePicker.data().bsYear,
                        bsMonth: $nepaliDatePicker.data().bsMonth,
                        bsDate: $nepaliDatePicker.data().bsDate
                    };
                    datePickerPlugin.renderCurrentMonthCalendar($nepaliDatePicker);
                    $nepaliDatePicker.data();
                    return datePickerPlugin.triggerChangeEvent($element, $nepaliDatePicker, preCalendarData), $nepaliDatePicker.show(), !1
                }), $nepaliDatePicker.on("click", ".current-year-txt, .current-month-txt", function() {
                    if ($(this).find(".drop-down-content").is(":visible")) $(this).find(".drop-down-content").hide();
                    else {
                        $nepaliDatePicker.find(".drop-down-content").hide(), $(this).find(".drop-down-content").show();
                        var $optionWrapper = $(this).find(".option-wrapper");
                        $optionWrapper.scrollTop(0);
                        var scrollTopTo = $optionWrapper.find(".active").position().top;
                        $optionWrapper.scrollTop(scrollTopTo)
                    }
                    return !1

                }),
                   $('.nepali-datepicker').on('keyup', function(){
                       date_regex = /\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])*/
                       date_value = $(this).val();
                       $('.nepali-datepicker').each(function(index){
                           $(this).attr('data-info', index);
                       })
                       $('.nepali-date-picker').each(function(index){
                           $(this).attr('data-info', index);
                       })
                       if(date_regex.test(date_value)){
                           date = $(this).val().split("-");
                           year = date[0];
                           month = date[1];
                           day  = date[2];
                           datePickerPlugin.setCalendarDate($nepaliDatePicker, parseInt(year), parseInt(month), parseInt(day));
                           datePickerPlugin.renderMonthCalendar($nepaliDatePicker);
                           data = $(this).data('info');
                           $('.nepali-date-picker').each(function(){
                               if(data == $(this).data('info')){
                                   $(this).show();
                               }
                           })
                           if($(this).next('.clear-date').length < 1){
                               $(this).after("<span class='clear-date' onclick='return false'>&times;</span>")
                               $(this).closest('.input-date-1, .input-date-2, .input-date-3, .st-row').css('height', '35px');
                           }$(this).next('.clear-date').show();
                       }else{
                           $(this).next('.clear-date').hide();
                       }
                   })
                    ,
                    $nepaliDatePicker.on("click", ".current-month-date", function() {
                    if (!$(this).hasClass("disable")) {
                        var datePickerData = $nepaliDatePicker.data(),
                            bsYear = datePickerData.bsYear,
                            bsMonth = datePickerData.bsMonth,
                            preDate = datePickerData.bsDate,
                            bsDate = $(this).data("date"),
                            dateText = calendarFunctions.bsDateFormat(datePickerPlugin.options.dateFormat, bsYear, bsMonth, bsDate);
                        return $element.val(dateText),datePickerPlugin.setCalendarDate($nepaliDatePicker, bsYear, bsMonth, bsDate), datePickerPlugin.renderMonthCalendar($nepaliDatePicker), preDate !== bsDate && datePickerPlugin.eventFire($element, $nepaliDatePicker, "dateChange"), datePickerPlugin.eventFire($element, $nepaliDatePicker, "dateSelect"), datePickerPlugin.options.closeOnDateSelect ? $nepaliDatePicker.hide() : $nepaliDatePicker.show(), !1
                    }
                }), $nepaliDatePicker.on("click", ".drop-down-content li", function() {
                    var $dropDown = $(this).parents(".drop-down-content");
                    $dropDown.data("value", $(this).data("value")), $dropDown.attr("data-value", $(this).data("value"));
                    var preCalendarData = {
                            bsYear: $nepaliDatePicker.data().bsYear,
                            bsMonth: $nepaliDatePicker.data().bsMonth,
                            bsDate: $nepaliDatePicker.data().bsDate
                        },
                        bsMonth = $nepaliDatePicker.find(".month-drop-down").data("value"),
                        bsYear = $nepaliDatePicker.find(".year-drop-down").data("value"),
                        bsDate = preCalendarData.bsDate;
                    datePickerPlugin.setCalendarDate($nepaliDatePicker, bsYear, bsMonth, bsDate), datePickerPlugin.renderMonthCalendar($nepaliDatePicker);
                    $nepaliDatePicker.data();
                    return datePickerPlugin.triggerChangeEvent($element, $nepaliDatePicker, preCalendarData), $nepaliDatePicker.show(), !1
                })
            },
            triggerChangeEvent: function($element, $nepaliDatePicker, preCalendarData) {
                var calendarData = $nepaliDatePicker.data();
                preCalendarData.bsYear !== calendarData.bsYear && datePickerPlugin.eventFire($element, $nepaliDatePicker, "yearChange"), preCalendarData.bsMonth !== calendarData.bsMonth && datePickerPlugin.eventFire($element, $nepaliDatePicker, "monthChange"), preCalendarData.bsDate !== calendarData.bsDate && datePickerPlugin.eventFire($element, $nepaliDatePicker, "dateChange")
            },
            eventFire: function($element, $nepaliDatePicker, eventType) {
                switch (eventType) {
                    case "generate":
                        $element.trigger({
                            type: eventType,
                            message: "Nepali date picker initialize",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        });
                        break;
                    case "show":
                        $element.trigger({
                            type: eventType,
                            message: "Show nepali date picker",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        });
                        break;
                    case "close":
                        $element.trigger({
                            type: eventType,
                            message: "close nepali date picker",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        });
                        break;
                    case "dateSelect":
                        $element.trigger({
                            type: eventType,
                            message: "Select date",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        });
                        break;
                    case "dateChange":
                        $element.trigger({
                            type: eventType,
                            message: "Change date",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        });
                        break;
                    case "monthChange":
                        $element.trigger({
                            type: eventType,
                            message: "Change month",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        });
                        break;
                    case "yearChange":
                        $element.trigger({
                            type: eventType,
                            message: "Change year",
                            datePickerData: $nepaliDatePicker.data(),
                            time: new Date
                        })
                }
            },
            setCalendarDate: function($nepaliDatePicker, bsYear, bsMonth, BsDate) {
                $nepaliDatePicker.data(calendarFunctions.getBsMonthInfoByBsDate(bsYear, bsMonth, BsDate, datePickerPlugin.options.dateFormat))
            },
            renderMonthCalendar: function($nepaliDatePicker) {
                $nepaliDatePicker.find(".calendar-wrapper").remove(), $nepaliDatePicker.append(datePickerPlugin.getCalendar($nepaliDatePicker)).hide()
            },
            getCalendar: function($nepaliDatePicker) {
                var calendarWrapper = $('<div class="calendar-wrapper">');
                calendarWrapper.append(datePickerPlugin.getCalendarController($nepaliDatePicker));
                var calendarTable = $("<table>");
                return calendarTable.append(datePickerPlugin.getCalendarHeader()), calendarTable.append(datePickerPlugin.getCalendarBody($nepaliDatePicker)), calendarWrapper.append(calendarTable), calendarWrapper
            },
            getCalendarController: function($nepaliDatePicker) {
                var calendarController = $("<div class='calendar-controller'>");
                return calendarController.append('<a href="javascript:void(0);" class="prev-btn icon" title="prev"></a>'), calendarController.append('<a href="javascript:void(0);" class="today-btn icon" title=""></a>'), calendarController.append(datePickerPlugin.getMonthDropOption($nepaliDatePicker)), calendarController.append(datePickerPlugin.getYearDropOption($nepaliDatePicker)), calendarController.append('<a href="javascript:void(0);" class="next-btn icon" title="next"></a>'), calendarController
            },
            getMonthDropOption: function($nepaliDatePicker) {
                var datePickerData = $nepaliDatePicker.data(),
                    $monthSpan = $('<div class="current-month-txt">');
                $monthSpan.text(calendarData.bsMonths[datePickerData.bsMonth - 1]), $monthSpan.append('<i class="icon icon-drop-down">');
                for (var data = [], i = 0; i < 12; i++) data.push({
                    label: calendarData.bsMonths[i],
                    value: i + 1
                });
                var $monthDropOption = datePickerPlugin.getCustomSelectOption(data, datePickerData.bsMonth).addClass("month-drop-down");
                return $monthSpan.append($monthDropOption), $monthSpan
            },
            getYearDropOption: function($nepaliDatePicker) {
                var datePickerData = $nepaliDatePicker.data(),
                    $yearSpan = $('<div class="current-year-txt">');
                $yearSpan.text(calendarFunctions.getNepaliNumber(datePickerData.bsYear)), $yearSpan.append('<i class="icon icon-drop-down">');
                for (var data = [], i = datePickerPlugin.options.yearStart; i <= datePickerPlugin.options.yearEnd; i++) data.push({
                    label: calendarFunctions.getNepaliNumber(i),
                    value: i
                });
                var $yearDropOption = datePickerPlugin.getCustomSelectOption(data, datePickerData.bsYear).addClass("year-drop-down");
                return $yearSpan.append($yearDropOption), $yearSpan
            },
            getCustomSelectOption: function(datas, activeValue) {
                var $dropDown = $('<div class="drop-down-content" data-value="' + activeValue + '">'),
                    $dropDownWrapper = $('<div class="option-wrapper">'),
                    $ul = $("<ul>");
                return $.each(datas, function(index, data) {
                    $ul.append('<li data-value="' + data.value + '">' + data.label + "</li>")
                }), $dropDownWrapper.append($ul), $ul.find('li[data-value="' + activeValue + '"]').addClass("active"), $dropDown.append($dropDownWrapper), $dropDown
            },
            getCalendarHeader: function() {
                for (var calendarHeader = $("<thead>"), tableRow = $("<tr>"), i = 0; i < 7; i++) tableRow.append("<td>" + calendarData.bsDays[i] + "</td>");
                return calendarHeader.append(tableRow), calendarHeader
            },
            getCalendarBody: function($nepaliDatePicker) {
                var datePickerData = $nepaliDatePicker.data(),
                    weekCoverInMonth = Math.ceil((datePickerData.bsMonthFirstAdDate.getDay() + datePickerData.bsMonthDays) / 7),
                    preMonth = datePickerData.bsMonth - 1 !== 0 ? datePickerData.bsMonth - 1 : 12,
                    preYear = 12 === preMonth ? datePickerData.bsYear - 1 : datePickerData.bsYear,
                    preMonthDays = preYear >= calendarData.minBsYear ? calendarFunctions.getBsMonthDays(preYear, preMonth) : 30,
                    minBsDate = null,
                    maxBsDate = null;
                null !== datePickerPlugin.options.minDate && (minBsDate = calendarFunctions.parseFormattedBsDate(datePickerPlugin.options.dateFormat, datePickerPlugin.options.minDate)), null !== datePickerPlugin.options.maxDate && (maxBsDate = calendarFunctions.parseFormattedBsDate(datePickerPlugin.options.dateFormat, datePickerPlugin.options.maxDate));
                for (var calendarBody = $("<tbody>"), i = 0; i < weekCoverInMonth; i++) {
                    for (var tableRow = $("<tr>"), k = 1; k <= 7; k++) {
                        var calendarDate = 7 * i + k - datePickerData.bsMonthFirstAdDate.getDay(),
                            isCurrentMonthDate = !0;
                        if (calendarDate <= 0 ? (calendarDate = preMonthDays + calendarDate, isCurrentMonthDate = !1) : calendarDate > datePickerData.bsMonthDays && (calendarDate -= datePickerData.bsMonthDays, isCurrentMonthDate = !1), isCurrentMonthDate) {
                            var $td = $('<td class="current-month-date" data-date="' + calendarDate + '" data-weekDay="' + (k - 1) + '">' + calendarFunctions.getNepaliNumber(calendarDate) + "</td>");
                            calendarDate == datePickerData.bsDate && $td.addClass("active"), datePickerPlugin.disableIfOutOfRange($td, datePickerData, minBsDate, maxBsDate, calendarDate), tableRow.append($td)
                        } else tableRow.append('<td class="other-month-date">' + calendarFunctions.getNepaliNumber(calendarDate) + "</td>")
                    }
                    calendarBody.append(tableRow)
                }
                return calendarBody
            },
            disableIfOutOfRange: function($td, datePickerData, minBsDate, maxBsDate, calendarDate) {
                return null !== minBsDate && (datePickerData.bsYear < minBsDate.bsYear ? $td.addClass("disable") : datePickerData.bsYear === minBsDate.bsYear && datePickerData.bsMonth < minBsDate.bsMonth ? $td.addClass("disable") : datePickerData.bsYear === minBsDate.bsYear && datePickerData.bsMonth === minBsDate.bsMonth && calendarDate < minBsDate.bsDate && $td.addClass("disable")), null !== maxBsDate && (datePickerData.bsYear > maxBsDate.bsYear ? $td.addClass("disable") : datePickerData.bsYear === maxBsDate.bsYear && datePickerData.bsMonth > maxBsDate.bsMonth ? $td.addClass("disable") : datePickerData.bsYear === maxBsDate.bsYear && datePickerData.bsMonth === maxBsDate.bsMonth && calendarDate > maxBsDate.bsDate && $td.addClass("disable")), $td
            },
            renderCurrentMonthCalendar: function($nepaliDatePicker) {
                var currentDate = new Date,
                    currentBsDate = calendarFunctions.getBsDateByAdDate(currentDate.getFullYear(), currentDate.getMonth() + 1, currentDate.getDate()),
                    bsYear = currentBsDate.bsYear,
                    bsMonth = currentBsDate.bsMonth,
                    bsDate = currentBsDate.bsDate;
                datePickerPlugin.setCalendarDate($nepaliDatePicker, bsYear, bsMonth, bsDate), datePickerPlugin.renderMonthCalendar($nepaliDatePicker)
            },
            renderPreviousMonthCalendar: function($nepaliDatePicker) {
                var datePickerData = $nepaliDatePicker.data(),
                    prevMonth = datePickerData.bsMonth - 1 > 0 ? datePickerData.bsMonth - 1 : 12,
                    prevYear = 12 !== prevMonth ? datePickerData.bsYear : datePickerData.bsYear - 1,
                    prevDate = datePickerData.bsDate;
                return prevYear < datePickerPlugin.options.yearStart || prevYear > datePickerPlugin.options.yearEnd ? null : (datePickerPlugin.setCalendarDate($nepaliDatePicker, prevYear, prevMonth, prevDate), void datePickerPlugin.renderMonthCalendar($nepaliDatePicker))
            },
            renderNextMonthCalendar: function($nepaliDatePicker) {
                var datePickerData = $nepaliDatePicker.data(),
                    nextMonth = datePickerData.bsMonth + 1 <= 12 ? datePickerData.bsMonth + 1 : 1,
                    nextYear = 1 !== nextMonth ? datePickerData.bsYear : datePickerData.bsYear + 1,
                    nextDate = datePickerData.bsDate;
                return nextYear < datePickerPlugin.options.yearStart || nextYear > datePickerPlugin.options.yearEnd ? null : (datePickerPlugin.setCalendarDate($nepaliDatePicker, nextYear, nextMonth, nextDate), void datePickerPlugin.renderMonthCalendar($nepaliDatePicker))
            },
            renderFormattedSpecificDateCalendar: function($nepaliDatePicker, dateFormat, dateFormattedText) {
                var datePickerDate = calendarFunctions.parseFormattedBsDate(dateFormat, dateFormattedText);
                datePickerPlugin.setCalendarDate($nepaliDatePicker, datePickerDate.bsYear, datePickerDate.bsMonth, datePickerDate.bsDate), datePickerPlugin.renderMonthCalendar($nepaliDatePicker)
            }
        };
        return this.each(function() {
            var $element = $(this);
            datePickerPlugin.init($element)
        }), datePickerPlugin.addCommonEventHandler(), this
    }
}(jQuery, calendarFunctions);