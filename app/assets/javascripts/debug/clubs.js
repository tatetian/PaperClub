$(function() {
  var Club = Backbone.Model.extend({
  });
  var Clubs = Backbone.Collection.extend({
    model: Club,
    url: '/api/clubs' 
  });
  var ClubView = Backbone.View.extend({
    tagName: 'li',
    initialize: function() {    
    },
    events: {
    },
    template: _.template($("#club-view-template").html()),
    render: function() {
      this.$el.empty();
      var json = this.model.toJSON();
      this.$el.append(this.template(json));
      return this;
    }
  });
  var ClubsView = Backbone.View.extend({
    el: "#club-list",
    initialize: function() {
      var that = this;
      this.collection.bind('add', that.addOne, that);
      this.collection.bind('reset', that.addAll, that);
    },
    addOne: function(model, that, options) {
      var clubView = new ClubView({model: model});
      this.$el.append(clubView.render().$el)
      window.clubEl = clubView.$el;
      console.debug(1);
    },
    addAll: function() {
      this.$el.empty();
      this.collection.each(this.addOne, this);      
    }
  });
  var clubs = new Clubs();
  var clubsView = new ClubsView({collection: clubs});
  clubs.fetch();
});
