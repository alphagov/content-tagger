//= require_tree .
//= require js.cookies.js
//= require jquery-ui/widgets/sortable
//= require jquery-ui/effects/effect-highlight
//= require Chart.bundle
//= require chartkick
//= require select2
//= require_self

$(document).ready(function() {
  $(".select2:not(.tagging_project)").select2({ allowClear: true });
});
