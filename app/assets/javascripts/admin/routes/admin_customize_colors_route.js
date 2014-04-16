/**
  Handles routes related to colors customization

  @class AdminCustomizeColorsRoute
  @extends Discourse.Route
  @namespace Discourse
  @module Discourse
**/
Discourse.AdminCustomizeColorsRoute = Discourse.Route.extend({

  model: function() {
    return Discourse.ColorScheme.findAll();
  }

});
