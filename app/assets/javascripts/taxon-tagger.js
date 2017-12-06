(function(Modules) {
  "use strict";

  // Constructor
  Modules.TaxonTagger = function(taxons) {
    this.selectors = {
      tag_input_element: '.js_bulk_tagger_input',
      bulk_tagger_form: '.js-bulk-tagger-form',
      content_item_forms: '.js-content-item-form',
      select_all_toggle: '.js-select-all',
      content_item_checkboxes: '.js-content-selector',
      selected_count: '.js-selected-count',
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

  Modules.TaxonTagger.prototype = {

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
            Waypoint.refreshAll();
          });
        }
      ).on(
        'ajax:error',
        function() {
          self.mark_form_as_failed_to_update($(this).parents('.content-item'));
        }
      );
    },

    /*
     * Initializes the Bulk Tagger interface
     * Where multiple content-items can be selected and tagged at the same time.
    **/
    start_bulk_tagger: function($element) {
      var self = this;

      var $bulk_tagger_form = $element.find(self.selectors.bulk_tagger_form);

      // Ajax response handlers for bulk tag form submission
      $bulk_tagger_form.on(
        "ajax:success",
        function(event, result) {
          result.forEach(function(data_item) {
            var $form = $("form[data-ref='" + data_item.content_id + "']");
            self.mark_form_as_successfully_updated($form, data_item.taxons);
          });
        }
      ).on(
        "ajax:error",
        function(event, data) {
          self.mark_form_as_failed_to_update($(this));
        }
      );

      // Contains all the content-item tagging forms
      var $content_item_forms = $element.find(self.selectors.content_item_forms);

      // Aligns the content-item selection checkboxes
      $content_item_forms.each(function(index, form) {
        var ref = $(form).attr('data-ref');
        var top_pos = $(form).position().top - 80 + "px";
        $('.content-selector[value="'+ ref +'"]').css("top", top_pos).css("display", "inherit");
      });

      // Contains a reference to every content-item selector
      var $content_item_checkboxes = $element.find(self.selectors.content_item_checkboxes);

      // This is the display element for the count of selected items
      var $selected_count = $element.find(self.selectors.selected_count);

      // Select All toggle
      $element.find(self.selectors.select_all_toggle).on(
        'change',
        function() {
          $content_item_checkboxes.prop('checked', this.checked);
          self.update_selected_count($selected_count, $content_item_checkboxes);
        }
      );

      // Handler to keep track of changes to the count of selected items
      $content_item_checkboxes.on(
        'change',
        function() {
          self.update_selected_count($selected_count, $content_item_checkboxes);
        }
      )
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
      var taxon_content_ids = Object.keys(taxons);
      var root_content_id = taxon_content_ids.shift();

      return taxon_content_ids.reduce(function(acc, taxon_id) {
        var ancestors = self.taxon_ancestors(taxon_id, taxons);
        ancestors.shift(); // lose the first ancestor, it's common to all taxons

        acc.push({
          "id": taxon_id,
          "text": ancestors.join(' > ')
        });
        return acc;
      }, [{
        "id": root_content_id,
        "text": taxons[root_content_id].name
      }]);
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

    // Tally of the number of content-items selected for bulk-tagging
    update_selected_count: function($selected_count, $content_item_checkboxes) {
      var count = this.count_of_selected_content_items($content_item_checkboxes);
      if(count == 0) {
        $selected_count.text('None');
      } else {
        $selected_count.text(count);
      }
    },

    // Given a $() of checkboxes, returns a count of the number of selected
    count_of_selected_content_items: function($content_item_checkboxes) {
      var checkbox_to_scalar = function($checkbox) {
        return $checkbox.checked ? 1 : 0;
      };

      var sum = function(total, increment) {
        return total + increment;
      };

      return $content_item_checkboxes
        .toArray()
        .map(checkbox_to_scalar)
        .reduce(sum, 0);
    }
  };
})(window.GOVUKAdmin.Modules);
