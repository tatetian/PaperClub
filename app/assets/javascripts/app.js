$(function() {
  PaperClub = {};

  // ==========================================
  //    App
  //
  //    This represents the entire application.
  // ==========================================
  var App = PaperClub.App = function() {
    this.initScreens();
    this.initRouter(); 
  };

  _.extend(App.prototype, Backbone.Events, {
    // Cache screens so that we don't need to create them repeatly
    cache: {
      clubsScreen: null,
      clubScreen: {},
      paperScreen: {} 
    },
    currentScreen: null,
    // Backbone routes are used for routing urls with hash tags(#).
    // This enables the user to switch between screens just by changing url.
    // No page refresh is needed.
    initRouter: function() {
      var that = this;

      var Router = Backbone.Router.extend({
        routes: {
          // e.g. "http://www.paperclub.me/app/#/clubs/1"
          "clubs/:club_id": "showClub",
          // e.g. "http://www.paperclub.me/app/#/papers/2"
          "papers/:paper_id": "showPaper",
          // e.g. "http://www.paperclub.me/app/#/clubs"
          "clubs": "showClubs",
          // default url
          "*actions": "showClubs"
        },
        showClubs: function(actions) {
          that.switchScreen(that.getCachedScreen("clubs"));
        },
        showClub: function(clubId) {
          that.switchScreen(that.getCachedScreen("club", clubId));
        },
        showPaper: function(paperId) {
          that.switchScreen(that.getCachedScreen("paper", paperId))
        }
      });
      var router = this.router = new Router();
      Backbone.history.start({root: "/app/#/"});
    },

    initScreens: function() {
                
    },

    switchScreen: function(newScreen) {
      if(this.currentScreen)
        this.currentScreen.hide();
      this.currentScreen = newScreen;
      newScreen.show();
    },

    getCachedScreen: function(name, id) {
      if(name=="clubs") {
        var clubsScreen = this.cache.clubsScreen;
        if (!clubsScreen) {
          clubsScreen = this.cache.clubsScreen 
                      = new AllClubsScreen({
                          userId: ""
                        });
        }
        return clubsScreen;
      }
      else if(name=="club") {
        var clubScreen = this.cache.clubScreen[id];
        if(!clubScreen) {
          clubScreen = this.cache.clubScreen[id]
                     = new OneClubScreen({
                         clubId: id
                       }); 
          return clubScreen;
        }
      }
      else if(name=="paper") {
        var paperScreen = this.cache.paperScreen[id]
                        = new PaperScreen({
                            paperId: id
                          }); 
        return paperScreen;
      }
    }
  });

  // ==========================================
  //    Screen
  //
  //    Screen is the building block of App. One Screen usually offers one 
  //    functionality. Users use the app by switching between different Screen.
  // ==========================================
  var Screen = PaperClub.screen = function(options) {

    Backbone.View.apply(this, [options]);
  }

  _.extend(Screen.prototype, Backbone.View.prototype, {
    visible: false,
    show: function() {
      if(this.visible)
        return;
      this.$el.appendTo("body").show();
      this.visible = true;
    },
    hide: function() {
      if(!this.visible)
        return;
      this.$el.detach().hide();      
      this.visible = false;
    } 
  });
    
  Screen.extend = Backbone.View.extend;

  // ==========================================
  //    AllClubsScreen
  // ==========================================
  var AllClubsScreen = PaperClub.AllClubsScreen = Screen.extend({
    className: "p-page-content shadow024 bgwhite",
    initialize: function(options) {
      this.render();

      this.initEvents();
    },
    template: _.template($("#clubs-screen-template").html()),
    initEvents: function() {
      var that = this;
      $(window).resize(function() { 
        if(this.visible) that.onResize() 
      });
    },
    render: function() {
      this.$el.empty()
              .append(this.template()); 
      this.onResize();
      return this;      
    },
    onResize: function() {
      // White area not too short
			this.$el.css('min-height' , 
                                    $(window).height() - 24*2);
      // Size of new club dialog
      var whtml=$(window).width();
			var wst_c=(whtml-48-255-18-36)*0.5;
			this.$('.newclub .m-m-container').css({"width":wst_c+88,"height":310});
    }
  });
  var InvitedClubView = Backbone.View.extend({
    tagName: "li",
    className: "font-c mb30 cf",
    template: _.template($("#invited-club-template").html()),
    render: function() {
      // TODO: jioajoidasioddas 
      this.$el.append(this.template({
        name: "",
        description: "",
     //.. 
      }));
    }
  });

  // ==========================================
  //    OneClubScreen
  // ==========================================
  var OneClubScreen = PaperClub.OneClubScreen = Screen.extend({
    initialize: function(options) {
    }
  });

  // ==========================================
  //    PaperScreen
  // ==========================================
  var PaperScreen = PaperClub.PaperScreen = Screen.extend({
    initialize: function(options) {
    } 
  });

  // ==========================================
  // Start application
  // =========================================
  var app = new App();

    
});
