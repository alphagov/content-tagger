(function(Modules) {
  "use strict";

  Modules.SelectAll = function() {
    var that = this;

    that.start = function(element) {
      addEventListener();

      function addEventListener() {
        var selectAll = element.find('#select_all');
        if (selectAll != undefined) {
          selectAll.on('change', function(e) {
            var checked = selectAll.prop('checked');
            var checkboxes = $('.select-content-item');
            checkboxes.prop('checked', checked);
          });
        }
      }
    }
  };
})(window.GOVUKAdmin.Modules);
