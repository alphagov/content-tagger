(function (Modules) {
  "use strict";

  Modules.RelatedContentTagger = function () {
    this.start = function () {

      $(".ordered-related-items").on("click", ".select2-search-choice-close", removeItem);
      $("#related_item_new_base_path").on("keypress", lookUpBasePathOnEnterPress);
      $("#lookup_base_path_button").on("click", lookUpBasePath);

      $(".related-content-item-entry .title").show();
      $(".related-content-item-entry .value").hide();
      $(".add-sortable-input").show();
      $(".sortable-inputs").sortable();


      function removeItem() {
        $(this).parents("li").remove();
        return false;
      }

      function lookUpBasePathOnEnterPress(event) {
        if (enterKeyPressed(event)) {
          lookUpBasePath();

          // Prevent form submission
          return false;
        }
      }

      function enterKeyPressed(event) {
        return event.keyCode === 13;
      }

      function lookUpBasePath() {
        var $basePathInput = $("#related_item_new_base_path");
        var basePath = $basePathInput.val();

        $.getJSON({
          url: "/taggings/lookup-urls?base_path=" + encodeURIComponent(basePath),
          success: onTagLookupSuccess,
          error: onTagLookupError
        });

        function onTagLookupSuccess(lookup) {
          var $templateTag = $(".related-item-template > li").first();

          var $newTag = $templateTag
            .clone()
            .appendTo(".ordered-related-items ul");

          $newTag
            .find("input")
            .attr("value", lookup.base_path);

          $newTag
            .find(".js-artefact-name")
            .text(lookup.title + " (" + lookup.base_path + ")")
            .attr("href", "https://www.gov.uk" + lookup.base_path);

          $basePathInput.val("");
          $basePathInput.removeClass("has-error");
          $(".related-item-error-message").hide();
        }

        function onTagLookupError(error) {
          $basePathInput.addClass("has-error");
          $(".related-item-error-message").show();
        }
      }
    };
  };
})(window.GOVUKAdmin.Modules);
