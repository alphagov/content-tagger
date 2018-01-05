(function (Modules) {
  "use strict";

  Modules.BasePathPreview = function () {
    this.start = function(el) {
      var $parentSelectEl = $('select.js-parent-taxon');
      var $pathSlugInputEl = $('input.js-path-slug');
      var $previewBasePathEl = $('.js-predicted-base-path');
      var rootContentID = el.data('root-content-id');

      updateBasePathPreview();
      $parentSelectEl.change(updateBasePathPreview);

      // Defer the lookup request when typing
      // until there has been a pause
      var timeout = null;
      $pathSlugInputEl.on('input', function() {
        clearTimeout(timeout);
        timeout = setTimeout(updateBasePathPreview, 500);
      });

      function updateBasePathPreview() {
        var parentTaxonContentId = $parentSelectEl.val();
        var url = window.location.origin + '/taxons/' + parentTaxonContentId + '.json';

        if (parentTaxonContentId.length !== 0 && parentTaxonContentId !== rootContentID ) {
          $.getJSON(url, function(taxon) {
            $previewBasePathEl.text('/' + taxon.path_prefix + '/' + $pathSlugInputEl.val());
          });
        } else {
          $previewBasePathEl.text('/' + $pathSlugInputEl.val());
        }
      }
    };
  };
})(window.GOVUKAdmin.Modules);
