DssRm.Views.ApplicationShow = Support.CompositeView.extend({
  tagName: "div",

  events: {
    "click a#apply"           : "saveApplication",
    "click a#delete"          : "deleteApplication",
    "hidden"                  : "cleanUpModal",
    "click button#add_role"   : "addRole",
    "click button#remove_role": "removeRole",
    "change table#roles input": "storeRoleChanges"
  },

  initialize: function(options) {
    this.model.on('add change remove sync', this.render, this);
    this.model.roles.on('add change remove sync reset', this.render, this);

    this.applications = options.applications;

    this.$el.html(JST['applications/show']({ application: this.model }));

    this.$("input[name=owners]").tokenInput(Routes.api_people_path(), {
      crossDomain: false,
      defaultText: "",
      theme: "facebook",
      tokenValue: "uid"
    });
  },

  render: function() {
    var self = this;

    // Summary tab
    self.$('h3').html(this.model.escape('name'));
    self.$('input[name=name]').val(this.model.get('name'));
    self.$('input[name=description]').val(this.model.get('description'));

    var owners_tokeninput = self.$("input[name=owners]");
    owners_tokeninput.tokenInput("clear");
    _.each(this.model.get('owners'), function(owner) {
      owners_tokeninput.tokenInput("add", {uid: owner.uid, name: owner.name});
    });

    // Roles tab
    self.$('table#roles tbody').empty();
    this.model.roles.each(function(role) {
      var roleItem = new DssRm.Views.ApplicationShowRole({ model: role });
      self.renderChild(roleItem);
      self.$('table#roles tbody').append(roleItem.el);
    });

    // Active Directory tab
    self.$('div#ad_fields').empty();
    this.model.roles.each(function(role) {
      var roleItem = new DssRm.Views.ApplicationShowAD({ model: role });
      self.renderChild(roleItem);
      self.$('div#ad_fields').append(roleItem.el);
    });

    return this;
  },

  saveApplication: function() {
    this.model.set({ name: this.$('input[name=name]').val() });

    this.model.save();

    return false;
  },

  deleteApplication: function() {
    var self = this;

    self.$el.fadeOut();
    bootbox.confirm("Are you sure you want to delete " + this.model.escape('name') + "?", function(result) {
      self.$el.fadeIn();

      if (result) {
        // delete the application and dismiss the dialog
        self.model.destroy();

        // dismiss the dialog
        self.$(".modal-header a.close").trigger("click");
      } else {
        // do nothing - do not delete
      }
    });

    return false;
  },

  cleanUpModal: function() {
    this.model.unbind('change', this.render, this);

    $("div#applicationShowModal").remove();
    // Need to change URL in case they want to open the same modal again
    Backbone.history.navigate("");
  },

  addRole: function() {
    // the false ID simply needs to be unique in case the 'remove' button is hit - our backend will provide a proper ID on saving
    this.model.roles.add({ id: 'new_' + Math.round((new Date()).getTime()) });

    return false;
  },

  removeRole: function(e) {
    var role_id = $(e.target).parents("tr").data("role_id");
    var role = this.model.roles.find(function(r) { return r.id == role_id });

    this.model.roles.remove(role);

    return false;
  },

  storeRoleChanges: function(e) {
    var rule_id = $(e.target).parents("tr").data("role_id");
    var role = this.model.roles.find(function(e) { return e.id == rule_id });

    role.set({
      token: $(e.target).parents("tr").find('input[name=token]').val(),
      default: $(e.target).parents("tr").find('input[name=default]').attr("checked") == "checked",
      descriptor: $(e.target).parents("tr").find('input[name=descriptor]').val(),
      description: $(e.target).parents("tr").find('input[name=description]').val()
    });
  }
});
