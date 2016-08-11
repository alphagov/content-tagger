(function(Modules) {
  "use strict";

  Modules.ImportProgress = function() {
    var that = this;

    that.start = function(element) {
      updateImportProgress();

      function updateImportProgress() {
        var currentProgress = element.find('.progress-bar').attr("aria-valuenow");
        var maxProgress = element.find('.progress-bar').attr("aria-valuemax");

        if (maxProgress - currentProgress != 0) {
          var progressPath = element.find('.js-import-progress').data('progress-path');
          var updatedProgress = $.get(progressPath).done(
            function(data) {
              element.find('.js-import-progress').replaceWith(data);
              setTimeout(updateImportProgress, 2000);
            }
          );
        }
      }
    }
  };
})(window.GOVUKAdmin.Modules);
