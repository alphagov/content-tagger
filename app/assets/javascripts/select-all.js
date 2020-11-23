(function (Modules) {
  'use strict'

  Modules.SelectAll = function () {
    var that = this

    that.start = function (element) {
      var selectAll = element.find('#select_all')

      function selectAllListener () {
        if (selectAll !== undefined) {
          selectAll.on('change', function (e) {
            var checkBoxes = $('.select-content-item:visible')
            var checked = selectAll.prop('checked')

            checkBoxes.prop('checked', checked)
          })
        };
      }

      function tableInputListner () {
        $('.js-filter-table-input').on('keyup change', function () {
          selectAll.prop('checked', false)
          $('.select-content-item').prop('checked', false)
        })
      };

      selectAllListener()
      tableInputListner()
    }
  }
})(window.GOVUKAdmin.Modules)
