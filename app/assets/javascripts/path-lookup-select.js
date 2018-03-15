(function(Modules) {
  "use strict";
  Modules.PathLookupSelect = function() {
    var moduleEl, formFieldName;

    this.start = function(element) {
      moduleEl = element;
      formFieldName = moduleEl.data('formFieldName');

      moduleEl.find("input[value='']").closest('li').remove();

      var $inputFields = moduleEl.find("input");
      $inputFields.prop('readonly', true);
      $inputFields.wrap('<div class="input-group"></div>');
      $inputFields.before('<span class="input-group-addon vertical-drag">&updownarrow;</span>');
      $inputFields.after(buildRemoveRelaltedItemEl());

      $('.js-list-sortable').sortable();

      moduleEl.append(buildAddRelatedItemEl())
    }

    var buildRemoveRelaltedItemEl = function() {
      var $buttonGroupEl = $('<span class="input-group-btn">');
      var $buttonEl = $('<button class="btn btn-default" type="button">Remove</button>');

      $buttonEl.on('click', function(e) {
        $(this).closest('li').remove();
      });

      $buttonGroupEl.append($buttonEl);
      return $buttonGroupEl;
    }

    var buildAddRelatedItemEl = function() {
      var $inputGroupEl = $('<div class="input-group">');
      var $inputEl = $('<input type="text" class="form-control js-path-field" placeholder="URL or path">');
      var $buttonGroupEl = $('<span class="input-group-btn"></span>');
      var $buttonEl = $('<button class="btn btn-default" type="button">Add path</button>')

      $inputEl.on('keypress', function(e) {
        if (e.keyCode == 13) { // Enter key
          e.preventDefault();
          if (this.value.length == 0) return;
          lookupBasePath(this.value);
        }
      });

      $buttonEl.on('click', function(e) {
        var inputValue = moduleEl.find("input.js-path-field").val();
        if (inputValue.length == 0) return;
        lookupBasePath(inputValue);
      });

      $inputGroupEl.append($inputEl);
      $buttonGroupEl.append($buttonEl);
      $inputGroupEl.append($buttonGroupEl);

      return $inputGroupEl;
    }

    var buildInputGroupEl = function(path) {
      var $listItemEl = $('<li></li>');
      var $inputGroupEl = $('<div class="input-group"></div>');
      var $dragEl = $('<span class="input-group-addon">↕</span>');
      var $inputEl = $('<input />', {
        type: 'text',
        name: formFieldName,
        value: path,
        class: 'form-control',
        readonly: true
      });

      $listItemEl.append($inputGroupEl);
      $inputGroupEl.append($dragEl);
      $inputGroupEl.append($inputEl);
      $inputGroupEl.append(buildRemoveRelaltedItemEl());

      return $listItemEl;
    }

    var lookupBasePath = function(path) {
      $.getJSON("/taggings/lookup-urls?base_path=" + encodeURIComponent(path))
        .done(function(contentId) {
          moduleEl.find(".js-path-field").removeClass('field-with-error')
          moduleEl.find(".js-add-path-error").addClass('hide')
          moduleEl.find('ul.js-base-path-list').append(buildInputGroupEl(path));
          moduleEl.find("input.js-path-field").val('');
        }).fail(function(error) {
          moduleEl.find(".js-add-path-error").removeClass('hide');
          moduleEl.find(".js-path-field").addClass('field-with-error')
        });
    }
  };
})(window.GOVUKAdmin.Modules);
