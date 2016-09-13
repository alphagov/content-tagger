(function(Modules) {
  "use strict";

  Modules.TagUpdateProgress= function() {
    var that = this;

    that.start = function(element) {
      updateProgressBar();

      function updateProgressBar() {
        var currentProgress = element.find('.progress-bar').attr("aria-valuenow");
        var maxProgress = element.find('.progress-bar').attr("aria-valuemax");

        if (maxProgress - currentProgress != 0) {
          var progressPath = element.find('.js-tag-update-progress').data('progress-path');
          var updatedProgress = $.get(progressPath).done(
            function(data) {
              element.find('.js-tag-update-progress').replaceWith(data);
              setTimeout(updateProgressBar, 2000);
            }
          );
        }
      }
    }
  };
})(window.GOVUKAdmin.Modules);
