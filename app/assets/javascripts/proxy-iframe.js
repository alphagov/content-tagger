(function (Modules) {
  "use strict";

  Modules.ProxyIframe = function () {
    this.start = function ($modalElement) {
      $modalElement.on('show.bs.modal', function (e) {
        var $relatedTarget = $(e.relatedTarget);

        $modalElement.find('iframe').attr('src', $relatedTarget.attr('data-modal-url'));
        $modalElement.find('h4').text($relatedTarget.text());
      });

      $modalElement.on('hidden.bs.modal', function(e) {
        // Once the modal is hidden, clear the contents, to avoid the
        // old contents showing momentarily when it's opened again.
        $modalElement.find('iframe').attr('src', 'about:blank');
      });
    };
  };
})(window.GOVUKAdmin.Modules);
