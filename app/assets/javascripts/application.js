//= require d3.v4.min.js
//= require_tree .
//= require js.cookies.js
//= require jquery-ui/widgets/sortable
//= require jquery-ui/effects/effect-highlight
//= require select2
//= require_self
//= require jquery.waypoints.min.js

$(document).ready(function() {
  $(".select2:not(.tagging_project):not(.bulk_tagger)").select2({ allowClear: true });

  // Facet tagging form, hide or show notification message.
  var $notificationMessage = $(".facets_tagging_update_form_notification_message");
  $("#facets_tagging_update_form_notify").change(function () {
    $notificationMessage.toggle(this.checked);
  });
});
