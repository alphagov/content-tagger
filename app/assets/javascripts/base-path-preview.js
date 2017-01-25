(function (Modules) {
  "use strict";

  Modules.BasePathPreview = function () {
    this.start = function() {
      var basePathWrapper = $('.js-base-path');
      var basePath = $('.js-base-path .base-path');
      var pathPrefix = $('select.js-path-prefix');
      var pathSlug = $('input.js-path-slug');

      pathPrefix.change(updateBasePathPreview);
      pathSlug.on('keyup', updateBasePathPreview);

      updateBasePathPreview();
      basePathWrapper.removeClass('hidden');

      function updateBasePathPreview() {
        basePath.html(pathPrefix.val() + pathSlug.val());
      }

    };
  };
})(window.GOVUKAdmin.Modules);
