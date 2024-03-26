(function (Modules) {
  'use strict'

  Modules.FilterableTable = function () {
    var that = this
    that.start = function (element) {
      var rows = element.find('tbody tr')
      var tableInput = element.find('.js-filter-table-input')
      var filterForm
      var rowCount
      var timeout = null

      element.on('keyup change', '.js-filter-table-input', function () {
        clearTimeout(timeout)
        timeout = setTimeout(function () {
          filterTableBasedOnInput()
        }, 600)
        $('.spinner').show()
      })

      if (element.find('a.js-open-on-submit').length > 0) {
        filterForm = tableInput.parents('form')
        if (filterForm && filterForm.length > 0) {
          filterForm.on('submit', openFirstVisibleLink)
        }
      }

      function filterTableBasedOnInput () {
        $('.spinner').hide()
        rowCount = 0
        var searchString = $.trim(tableInput.val())
        var regExp = new RegExp(escapeStringForRegexp(searchString), 'i')

        rows.each(function () {
          var row = $(this)
          if (row.text().search(regExp) > -1) {
            row.css({ display: 'table-row' })
            ++rowCount
          } else {
            row.css({ display: 'none' })
          }
        })

        $('#row-count').text('Filtered results count: ' + rowCount)
      }

      function openFirstVisibleLink (evt) {
        evt.preventDefault()
        var link = element.find('a.js-open-on-submit:visible').first()
        GOVUKAdmin.redirect(link.attr('href'))
      }

      function escapeStringForRegexp (str) {
        // https://github.com/tc39/proposal-regex-escaping
        return str.replace(/[\\^$*+?.()|[\]{}]/g, '\\$&')
      }
    }
  }
})(window.GOVUKAdmin.Modules)
