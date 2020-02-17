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
});
