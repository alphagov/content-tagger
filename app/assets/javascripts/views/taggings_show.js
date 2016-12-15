$(document).ready(function() {
  "use strict";

  $(".sortable-inputs .title").show();
  $(".sortable-inputs .value").hide();
  $(".add-sortable-input").show();
  $(".sortable-inputs").sortable();

  $("#ordered_related_items").on('click', ".select2-search-choice-close", function() {
    $(this).parents("li").remove();
    return false;
  });

  // Prevent default behaviour of submitting form on enter, when adding
  // a new related link.
  // TODO: don't make this part of the main form in the first place
  $('#related_item_new_base_path').on('keypress', function() {
    if(event.keyCode === 13) {
      $("#lookup_base_path_button").click();
      return false;
    } else {
      return true;
    }
  });

  $("#lookup_base_path_button").on('click', function() {
    var basePathInput = $("#related_item_new_base_path");
    var basePath = basePathInput.val();
    if (basePath !== "") {
      $.get({
        url: "/taggings/lookup/" + encodeURIComponent(basePath.replace(/^\//, "")),
        dataType: "json"
      }).done(function(lookup, textStatus, jqXHR) {
        if (jqXHR.status === 200) {
          // TODO: use a template instead of this (share template between front and backend)
          var existing = $("#ordered_related_items li");
          var lastTag = existing.first();
          var newTag = lastTag.clone().appendTo("#ordered_related_items ul");
          newTag.find("input").attr("value", lookup.base_path);
          newTag.find(".js-artefact-name").text(lookup.title).attr("href", "https://www.gov.uk" + lookup.base_path);

          basePathInput.val("");
        } else {
          // TODO: display errors
        }
      }).fail(function() {
        // TODO: display errors
      });
    }
  });
});
