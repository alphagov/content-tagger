$(function updateImportProgress() {
  var $importProgress = $('.js-import-progress');
  if ($importProgress.length == 0) { return; }

  var currentProgress = $importProgress.find('.progress-bar').attr("aria-valuenow");
  var maxProgress = $importProgress.find('.progress-bar').attr("aria-valuemax");

  // Don't poll for progress if the counter sits at zero - means you have to
  // refresh the page a couple of times to see progress but avoids pointless
  // network requests in cases where an import hasn't begun yet.
  if (currentProgress == 0) { return; }

  if (maxProgress - currentProgress != 0) {
    var progressPath = $importProgress.data('progress-path');
    var updatedProgress = $.get(progressPath).done(
      function(data) {
        $importProgress.replaceWith(data);
        setTimeout(updateImportProgress, 2000);
      }
    );
  }
});

