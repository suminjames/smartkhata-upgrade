/*! Smartkhata plugin js
 * ================
 * JS file for Smartkhata. It controls some layout
 * options and implements exclusive Smartkhata plugins.
 *
 * @Author  Subas Poudel
 * @Support <http://www.almsaeedstudio.com>
 * @Email   <subas@poudelsubas.com>
 * @version 16.05.24.0
 * @license MIT <http://opensource.org/licenses/MIT>
 */

'use strict';

//Make sure jQuery has been loaded before
if (typeof jQuery === "undefined") {
    throw new Error("SmartKhata requires jQuery");
}

/* SmartKhata
 *
 * @type Object
 * @description $.SmartKhata is the main object for the smartkhata.
 *              It's used for implementing functions and options.
 *              Keeping everything wrapped in an object
 *              prevents conflict with other plugins and is a better
 *              way to organize our code.
 */
$.SmartKhata = {};

/* --------------------
 * - SmartKhata Options -
 * --------------------
 * Modify these options to suit your implementation
 */
$.SmartKhata.options = {
    //General animation speed for JS animated elements. This options accepts an integer as milliseconds,
    //'fast', 'normal', or 'slow'
    animationSpeed: 500,
    //BoxRefresh Plugin
    enableBoxRefresh: true,
    //Box Widget Plugin. Enable this plugin
    //to allow boxes to be collapsed and/or removed
    enableBoxWidget: true,
    //Box Widget plugin options
    boxWidgetOptions: {
        boxWidgetIcons: {
            //Collapse icon
            collapse: 'fa-minus',
            //Open icon
            open: 'fa-plus',
            //Remove icon
            remove: 'fa-times'
        },
        boxWidgetSelectors: {
            //Remove button selector
            remove: '[data-widget="remove"]',
            //Collapse button selector
            collapse: '[data-widget="collapse"]'
        }
    }
};

/* ------------------
 * - Implementation -
 * ------------------
 * The next block of code implements SmartKhata's
 * functions and plugins as specified by the
 * options above.
 */
$(function () {
    //Extend options if external options exist
    if (typeof SmartKhataOptions !== "undefined") {
        $.extend(true,
            $.SmartKhata.options,
            SmartKhataOptions);
    }

    //Easy access to options
    var o = $.SmartKhata.options;

    //Set up the object
    _smartkhata_init();

    //Activate box widget
    if (o.enableBoxWidget) {
        $.SmartKhata.boxWidget.activate();
    }
});

/* ----------------------------------
 * - Initialize the SmartKhata Object -
 * ----------------------------------
 * All SmartKhata functions are implemented below.
 */
function _smartkhata_init() {
    
    /* Tree()
     * ======
     * Converts the sidebar into a multilevel
     * tree view menu.
     *
     * @type Function
     * @Usage: $.SmartKhata.tree('.sidebar')
     */
    $.SmartKhata.tree = function (menu) {
        var _this = this;
        var animationSpeed = $.SmartKhata.options.animationSpeed;
        $("li a", $(menu)).on('click', function (e) {
            //Get the clicked link and the next element
            var $this = $(this);
            var checkElement = $this.next();

            //Check if the next element is a menu and is visible
            if ((checkElement.is('.treeview-menu')) && (checkElement.is(':visible'))) {
                //Close the menu
                checkElement.slideUp(animationSpeed, function () {
                    checkElement.removeClass('menu-open');
                    //Fix the layout in case the sidebar stretches over the height of the window
                    //_this.layout.fix();
                });
                checkElement.parent("li").removeClass("active");
            }
            //If the menu is not visible
            else if ((checkElement.is('.treeview-menu')) && (!checkElement.is(':visible'))) {
                //Get the parent menu
                var parent = $this.parents('ul').first();
                //Close all open menus within the parent
                var ul = parent.find('ul:visible').slideUp(animationSpeed);
                //Remove the menu-open class from the parent
                ul.removeClass('menu-open');
                //Get the parent li
                var parent_li = $this.parent("li");

                //Open the target menu and add the menu-open class
                checkElement.slideDown(animationSpeed, function () {
                    //Add the class active to the parent li
                    checkElement.addClass('menu-open');
                    parent.find('li.active').removeClass('active');
                    parent_li.addClass('active');
                    //Fix the layout in case the sidebar stretches over the height of the window
                    _this.layout.fix();
                });
            }
            //if this isn't a link, prevent the page from being redirected
            if (checkElement.is('.treeview-menu')) {
                e.preventDefault();
            }
        });
    };

    /* BoxWidget
     * =========
     * BoxWidget is a plugin to handle collapsing and
     * removing boxes from the screen.
     *
     * @type Object
     * @usage $.SmartKhata.boxWidget.activate()
     *        Set all your options in the main $.SmartKhata.options object
     */
    $.SmartKhata.boxWidget = {
        selectors: $.SmartKhata.options.boxWidgetOptions.boxWidgetSelectors,
        icons: $.SmartKhata.options.boxWidgetOptions.boxWidgetIcons,
        animationSpeed: $.SmartKhata.options.animationSpeed,
        activate: function (_box) {
            var _this = this;
            if (! _box) {
                _box = document; // activate all boxes per default
            }
            //Listen for collapse event triggers
            $(_box).find(_this.selectors.collapse).on('click', function (e) {
                e.preventDefault();
                _this.collapse($(this));
            });

            //Listen for remove event triggers
            $(_box).find(_this.selectors.remove).on('click', function (e) {
                e.preventDefault();
                _this.remove($(this));
            });
        },
        collapse: function (element) {
            var _this = this;
            //Find the box parent
            var box = element.parents(".box").first();
            //Find the body and the footer
            var box_content = box.find("> .box-body, > .box-footer");
            if (!box.hasClass("collapsed-box")) {
                //Convert minus into plus
                element.children(":first")
                    .removeClass(_this.icons.collapse)
                    .addClass(_this.icons.open);
                //Hide the content
                box_content.slideUp(_this.animationSpeed, function () {
                    box.addClass("collapsed-box");
                });
            } else {
                //Convert plus into minus
                element.children(":first")
                    .removeClass(_this.icons.open)
                    .addClass(_this.icons.collapse);
                //Show the content
                box_content.slideDown(_this.animationSpeed, function () {
                    box.removeClass("collapsed-box");
                });
            }
        },
        remove: function (element) {
            //Find the box parent
            var box = element.parents(".box").first();
            box.slideUp(this.animationSpeed);
        }
    };
}