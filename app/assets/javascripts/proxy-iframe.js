(function (Modules) {
  "use strict";

  Modules.ProxyIframe = function () {
    this.start = function () {
      $('[data-proxy-iframe]').click(
         function (e) {
           e.preventDefault();
           $("#iframe_id").contents().find("body").html('');
           $('#iframe_id').attr('src', $(this).attr('data-modal-url'));
           $('#iframe_modal_label_id').html($(this).text());
         }
      );
    };
  };
})(window.GOVUKAdmin.Modules);
