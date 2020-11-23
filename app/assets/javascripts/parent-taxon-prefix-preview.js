(function (Modules) {
  'use strict'

  Modules.ParentTaxonPrefixPreview = function () {
    this.start = function (el) {
      var $parentSelectEl = $(el).find('select.js-parent-taxon')
      var $pathPrefixEl = $(el).find('.js-path-prefix-hint')
      var $taxonBasePathEl = $(el).find('#taxon_base_path')

      function getParentPathPrefix (callback) {
        var parentTaxonContentId = $parentSelectEl.val()

        if (parentTaxonContentId.length === 0) {
          callback()
          return
        }

        $.getJSON(
          window.location.origin + '/taxons/' + parentTaxonContentId + '.json'
        ).done(function (taxon) {
          callback(taxon.path_prefix)
        })
      }

      function updateBasePathPreview () {
        getParentPathPrefix(function (pathPrefix) {
          if (pathPrefix) {
            $pathPrefixEl.html('Base path must start with <b>/' + pathPrefix + '</b>')
            $pathPrefixEl.removeClass('hidden')
          } else {
            $pathPrefixEl.addClass('hidden')
            $pathPrefixEl.text('')
          }
        })
      }

      getParentPathPrefix(function (pathPrefix) {
        if ($taxonBasePathEl.val().length !== 0) {
          return
        }

        if (pathPrefix) {
          $taxonBasePathEl.val('/' + pathPrefix + '/')
        }
      })

      updateBasePathPreview()
      $parentSelectEl.change(updateBasePathPreview)
    }
  }
})(window.GOVUKAdmin.Modules)
