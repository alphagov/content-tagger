(function (Modules) {
  'use strict'

  Modules.RelatedContentTagger = function () {
    this.start = function (fieldset) {
      var $fieldset = $(fieldset)
      var $basePathInput = $fieldset.find('.new-base-path')
      var $lookupButton = $fieldset.find('.lookup-base-path-button')
      var $tagList = $fieldset.find('ul')
      var $templateTag = $fieldset.find('.related-item-template > li').first()
      var $fieldErrors = $fieldset.find('.related-item-error-message')

      $fieldset.on('click', '.js-remove-related', removeItem)
      $basePathInput.on('keypress', lookUpBasePathOnEnterPress)
      $lookupButton.on('click', lookUpBasePath)

      $fieldset.find('.related-content-item-entry .title').show()
      $fieldset.find('.related-content-item-entry .value').hide()
      $fieldset.find('.add-sortable-input').show()
      $fieldset.find('.sortable-inputs').sortable()

      function removeItem () {
        $(this).parents('li').remove()
        return false
      }

      function lookUpBasePathOnEnterPress (event) {
        if (enterKeyPressed(event)) {
          lookUpBasePath()

          // Prevent form submission
          return false
        }
      }

      function enterKeyPressed (event) {
        return event.keyCode === 13
      }

      function lookUpBasePath () {
        var basePath = $basePathInput.val()

        $.getJSON({
          url: '/taggings/lookup-urls?base_path=' + encodeURIComponent(basePath),
          success: onTagLookupSuccess,
          error: onTagLookupError
        })

        function onTagLookupSuccess (lookup) {
          var $newTag = $templateTag
            .clone()
            .appendTo($tagList)

          $newTag
            .find('input')
            .attr('value', lookup.base_path)

          $newTag
            .find('.js-artefact-name')
            .text(lookup.title + ' (' + lookup.base_path + ')')
            .attr('href', 'https://www.gov.uk' + lookup.base_path)

          $basePathInput.val('')
          $basePathInput.removeClass('has-error')
          $fieldErrors.hide()
        }

        function onTagLookupError (error) { // eslint-disable-line node/handle-callback-err
          $basePathInput.addClass('has-error')
          $fieldErrors.show()
        }
      }
    }
  }
})(window.GOVUKAdmin.Modules)
