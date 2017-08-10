//= require_tree .
//= require select2
//= require js.cookies.js
//= require_self
//= require jquery-ui
//= require Chart.bundle
//= require chartkick
//= require vendor/datatables.min
//= require jquery_ujs

$(document).ready(function() {
  $(".select2:not(.tagging_project)").select2({ allowClear: true });
});
