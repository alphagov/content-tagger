(function (Modules) {
  "use strict";

  Modules.ParentTaxonPrefixPreview = function () {
    this.start = function(el) {
      var $parentSelectEl = $(el).find('select.js-parent-taxon');
      var $pathPrefixEl = $(el).find('.js-path-prefix-hint');

      updateBasePathPreview();
      $parentSelectEl.change(updateBasePathPreview);

      function updateBasePathPreview() {
        var parentTaxonContentId = $parentSelectEl.val();

        if (parentTaxonContentId.length === 0) {
          $pathPrefixEl.addClass('hidden');
          $pathPrefixEl.text('');
          return;
        }

        $.getJSON(
          window.location.origin + '/taxons/' + parentTaxonContentId + '.json'
        ).done(function(taxon) {
          if (typeof taxon.path_prefix !== 'undefined') {
            $pathPrefixEl.html('Base path must start with <b>/' + taxon.path_prefix + '</b>');
            $pathPrefixEl.removeClass('hidden');
          } else {
            $pathPrefixEl.addClass('hidden');
            $pathPrefixEl.text('');
          }
        });
      }
    };
  };
})(window.GOVUKAdmin.Modules);
