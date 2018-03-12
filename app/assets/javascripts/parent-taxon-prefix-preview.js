(function (Modules) {
  "use strict";

  Modules.ParentTaxonPrefixPreview = function () {
    this.start = function(el) {
      var $parentSelectEl = $(el).find('select.js-parent-taxon');
      var $pathPrefixEl = $(el).find('.js-path-prefix-hint');
      var $taxonBasePathEl = $(el).find('#taxon_base_path');

      function getParentPathPrefix(callback) {
        var parentTaxonContentId = $parentSelectEl.val();

        if (parentTaxonContentId.length === 0) {
          callback();
          return;
        }

        $.getJSON(
          window.location.origin + '/taxons/' + parentTaxonContentId + '.json'
        ).done(function(taxon) {
          callback(taxon.path_prefix);
        });
      }

      function updateBasePathPreview() {
        getParentPathPrefix(function (path_prefix) {
          if (path_prefix) {
            $pathPrefixEl.html('Base path must start with <b>/' + path_prefix + '</b>');
            $pathPrefixEl.removeClass('hidden');
          } else {
            $pathPrefixEl.addClass('hidden');
            $pathPrefixEl.text('');
          }
        });
      }

      getParentPathPrefix(function (path_prefix) {
        if (path_prefix) {
          $taxonBasePathEl.val('/'+ path_prefix + '/');
        }
      });

      updateBasePathPreview();
      $parentSelectEl.change(updateBasePathPreview);
    };
  };
})(window.GOVUKAdmin.Modules);
