(function(Modules) {
  "use strict";

  // Constructor
  Modules.BulkTagger = function(taxons) {
    this.selectors = {
      tag_input_element: '.js_bulk_tagger_input',
      content_item_forms: '.js-content-item-form',
      done_form_selector: '.js-mark-as-done'
    }

    this.form_error_class = 'error-saving';
    this.color_of_success = "#d8f3d8";

    this.options_for_select2 = {
      allowClear: true,
      multiple: true,
      data: this.taxons_for_select2(taxons),
      formatSelection: this.format_selected_taxon
    }
  };

  Modules.BulkTagger.prototype = {

    /*
     * Initializes each content-item tagging form with Select2 and auto-save.
    **/
    start_individual_taggers: function($element) {
      var self = this;

      /*
       * Initialise tag input selects, but only once they become
       * visible aka on-screen.
       */
      $element.find(self.selectors.tag_input_element).waypoint({
        handler: function(_) {
          var $this = $(this.element),
              taxons = $this.data('taxons'),
              options = self.options_for_select2;

          // remove 'disabled' attribute from input element
          $this.prop('disabled', false);

          // populate with previously selected taxons, and initialize select2
          $this.val(taxons).select2(options);

          // remove waypoint
          this.destroy();
        },
        offset: 'bottom-in-view'
      });

      // Contains all the content-item tagging forms
      var $content_item_forms = $element.find(self.selectors.content_item_forms);

      // Individual content-item forms save on change
      $content_item_forms.find('.select2').on(
        'change',
        function(event) {
          $(this).parents('form').trigger('submit.rails');
        }
      );

      // Ajax response handlers for individual content-item form submissions
      $content_item_forms.on(
        'ajax:success',
        function() {
          self.mark_form_as_successfully_updated($(this));
        }
      ).on(
        'ajax:error',
        function() {
          self.mark_form_as_failed_to_update($(this));
        }
      );

      $element.find(self.selectors.done_form_selector).on(
        'ajax:success',
        function() {
          $(this).parents('.content-item').fadeOut('fast', function() {
            $(this).remove();
          });
        }
      ).on(
        'ajax:error',
        function() {
          self.mark_form_as_failed_to_update($(this).parents('.content-item'));
        }
      );
    },

    /**
     * Given:
     * {
     *   "206b7f3a-49b5-476f-af0f-fd27e2a68473": "Parenting, childcare and children's services"
     * }
     *
     * Returns an array of objects suitable for initializing a select2 element:
     * [{
     *   "id": "206b7f3a-49b5-476f-af0f-fd27e2a68473",
     *   "text": "Parenting, childcare and children's services"
     * }]
    **/
    taxons_for_select2: function(taxons) {
      var self = this;
      return Object.keys(taxons).reduce(function(acc, taxon_id) {
        var ancestors = self.taxon_ancestors(taxon_id, taxons);
        ancestors.shift(); // lose the first ancestor, it's common to all taxons

        acc.push({
          "id": taxon_id,
          "text": ancestors.join(' > ')
        });
        return acc;
      }, []);
    },

    // Returns the ancestors array of taxon names
    taxon_ancestors: function(taxon_id, taxons) {
      var taxon = taxons[taxon_id];

      if(taxon.parent_id !== null) {
        return this.taxon_ancestors(taxon.parent_id, taxons).concat(taxon.name);
      }
      else {
        return [taxon.name];
      }
    },

    // renders the selected tag
    format_selected_taxon: function(data) {
      return data.text.split(' > ').pop();
    },

    // display a brief message next to a form
    display_response_state: function($formEl, message) {
      $formEl.siblings(".js-save-state")
        .text(message)
        .delay(700)
        .animate({ opacity: 0 }, 300, 'linear', function() {
          var $textEl = $(this)
          $textEl.html("&nbsp;");
          $textEl.css({ opacity: 1 })
        });
    },

    // Green flash of success
    mark_form_as_successfully_updated: function($form, taxons) {
      $form.removeClass(this.form_error_class);
      $form.effect("highlight", { color: this.color_of_success }, 1000);

      this.display_response_state($form, "Saved");

      if(typeof taxons !== 'undefined') {
        var $select2 = $form.find('.select2');
        $select2.data('taxons', taxons);
        this.update_select2_with_new_taxons($select2);
      }
    },

    update_select2_with_new_taxons: function($select2) {
      var taxons = $select2.data('taxons');
      $select2.select2('val', taxons);
    },

    // Red background of failure
    mark_form_as_failed_to_update: function($form) {
      this.display_response_state($form, "Failed to save");
      $form.addClass(this.form_error_class);
    },
  };
})(window.GOVUKAdmin.Modules);
