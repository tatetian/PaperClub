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
          clubId = parseInt(clubId);
          that.switchScreen(that.getCachedScreen("club", clubId));
        },
        showPaper: function(paperId) {
          paperid = parseInt(paperId);
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
                         id: id
                       }); 
        }
        return clubScreen;
      }
      else if(name=="paper") {
        var paperScreen = this.cache.paperScreen[id];
        if(!paperScreen) {
          paperscreen = this.cache.paperScreen[id]
                      = new PaperScreen({
                          id: id
                        });
        } 
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
    initialize: function() {
      this.render();

      this.initEvents();

      this.clubs = SharedData.getClubs();
      this.clubs.on('add', this.onAddOne, this)
                .on('reset', this.onAddAll, this)
                .fetch();
    },
    template: _.template($("#clubs-screen-template").html()),
    initEvents: function() {
      var that = this;
      this.$(".c-btn-newclub").click(function(e) {
        that.onNewClub();
        e.preventDefault();
      });
      $(window).resize(function() { 
        if(that.visible) that.onResize() 
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
			this.$el.css('min-height', $(window).height() - 24*2);
    },
    onNewClub: function() {
      if(!this.newClubDialoge)
        this.newClubDialoge = new NewClubDialoge();
      this.newClubDialoge.show();
    },
    onAddOne: function(club, that, options) {
      var clubView = new JoinedClubView({club: club});
      this.$("ul").append(clubView.render().$el)
    },
    onAddAll: function() {
      this.$("ul").empty();
      this.clubs.each(this.onAddOne, this);      
    }
  });

  var NewClubDialoge = Backbone.View.extend({
    className: "m-m-wrapper newclub",
    template: _.template($("#new-club-dialoge-template").html()),
    visible: false,
    events: {
      "click .c-btn-creatclub": "onOK"
    },
    initialize: function() {
      var that = this;

      $(window).size(function() {
        if(that.visible)
          that.onResize();
      });
    },
    render: function() {
      return this;
    },
    show: function() {
      this.$el.appendTo($("body")).show();
      this.visible = true;

      this.model = new Club();

      this.$el.empty()
              .append(this.template(this.model.toJSON()));
      this.onResize();
    },
    hide: function() {
      this.$el.detach().hide();
      this.visible = false;
    },
    onResize: function() {
      // Size of new club dialog
      var whtml = $(window).width();
			var wst_c = (whtml-48-255-18-36)*0.5;
			this.$('.m-m-container').css({"width":wst_c+88,"height":310});
    },
    onOK: function(e) {
      this.model.set(this.retrieveValues())
                .save();  
      
      this.hide();

      e.preventDefault();
    },
    retrieveValues: function() {
      var emails = [];
      _.forEach([0,1,2], function(i) { 
        var email = $.trim( this.$("#new-club-email-"+i).text() );
        if(email.length > 0)
          emails.push(email);
      });

      return {
        name: this.$("#new-club-name").text(),
        description: this.$("#new-club-description").text(),
        invitation_emails: emails 
      };
    }
  });

  var InvitedClubView = Backbone.View.extend({
    tagName: "li",
    className: "font-c mb30 cf",
    template: _.template($("#invited-club-template").html()),
    render: function() { 
      this.$el.append(this.template({
        name: "Club's name",
        description: "Club's description",
        num_papers: 0,
        num_members: 0,
        num_notes: 0,
        invitor_name: "..."
      }));
      return this;
    }
  });

  var JoinedClubView = Backbone.View.extend({
    tagName: "li",
    className: "font-c mb30 cf",
    template: _.template($("#joined-club-template").html()),
    initialize: function() {
      this.club = this.options.club;
    },
    render: function() {
      var json = this.club.toJSON();
      json.avatar_urls = json.users.map(function(u) {
                            return u.avatar_url;
                         });
      this.$el.append(this.template(json));
      /* {
        name: "Club's name",
        description: "Club's description",
        num_papers: 0,
        num_members: 0,
        num_notes: 0,
        avatar_urls: []
      }*/
      return this;
    }
  });

  var Club = PaperClub.Club = Backbone.Model.extend({
    urlRoot: "/api/clubs/",
    defaults: function() {
      return {
        "name": "Name the club",
        "description": "Add a description or extra details(optional)",
        "invitation_emails": ["", "", ""]
      }
    }
  });

  var Clubs = PaperClub.Clubs = Backbone.Collection.extend({
    model: Club,
    url: "/api/clubs"
  });


  // ==========================================
  //    OneClubScreen
  // ==========================================
  var OneClubScreen = PaperClub.OneClubScreen = Screen.extend({
    className: "p-page-content shadow024 bgwhite",
    template: _.template($("#club-screen-template").html()),
    initialize: function() {
      this.id = this.options.id;
      this.summaryView = new ClubScreenSummaryView({id: this.id});
      this.paperListView = new PaperListView({clubId: this.id});

      this.initEvents();

      this.render(); 
    },
    initEvents: function() {
      var that = this;
      
      $(window).resize(function() { 
        if(that.visible) that.onResize() 
      });
    },
    render: function() {
      this.$el.empty()
              .append(this.template())
              .append(this.paperListView.render().$el)
              .find(".p-sidebar").prepend(this.summaryView.render().$el);
      this.onResize();
      return this;      
    },
    onResize: function() {
      // White area shoudl not be too short
			this.$el.css('min-height', $(window).height() - 24*2);
    }
  });

  var ClubScreenSummaryView = Backbone.View.extend({
    className: "section",
    template: _.template($("#club-screen-summary-template").html()),
    initialize: function() {
      this.id = this.options.id;
      this.club = SharedData.getClub(this.id); 

      this.club.on("change", this.render, this)
               .fetch();
    },
    render: function() {
      this.$el.empty()
              .append(this.template(this.club.toJSON()));
      return this; 
    }
  });

  var PaperListView = Backbone.View.extend({
    className: "p-paper-list",
    template: _.template($("#club-screen-paper-list").html()),
    initialize: function() {
      this.clubId = this.options.clubId;

      this.$el.append(this.template());

      this.initEvents();

      this.papers = new Papers(null, {clubId: this.clubId});//SharedData.getPapers(this.clubId);
      this.papers.on('add', this.onAddOne, this)
                 .on('reset', this.onAddAll, this);
    },
    initEvents: function() {
    },
    render: function() {
      this.papers.fetch();
      return this; 
    },
    onAddOne: function(paper, that, options) {
      var paperView = new PaperItemView({paper: paper});
      this.$("ul").append(paperView.render().$el)
    },
    onAddAll: function() {
      this.$("ul").empty();
      this.papers.each(this.onAddOne, this);      
    }
  });

  var PaperItemView = Backbone.View.extend({
    tagName: "li",
    className: "mb30 clearfloat",
    template: _.template($("#club-screen-paper-item").html()), 
    initialize: function() {
      this.paper = this.options.paper;

      this.paper.on('change', this.render, this);
    },
    render: function() {
      this.$el.empty()
              .append(this.template({
                        //this.paper.toJSON()
                        title: this.paper.get('title'),
                        num_favs: 0,
                        num_reads: 0,
                        num_notes: 0,
                        tags: this.paper.get('tags'),
                        news: {
                          content: "",
                          timestamp: "Just now",
                          action: "uploaded",
                          author: "Tate Tian",
                          avatar_url: ""
                        }
                      }));
      return this;       
    }
  });

  var Paper = PaperClub.Paper = Backbone.Model.extend({
    urlRoot: "/api/papers"
  });

  var Papers = PaperClub.Papers = Backbone.Collection.extend({
    model: Paper,
    url: function() { 
      return "/api/clubs/" + this.clubId + "/papers";
    },
    initialize: function(models, options) {
      this.clubId = options.clubId;            
    }
  });

  // ==========================================
  //    PaperScreen
  // ==========================================
  var PaperScreen = PaperClub.PaperScreen = Screen.extend({
    initialize: function() {
    } 
  });

  // ==========================================
  //    SharedStore
  //
  //    All collections and models in SharedStore are shared among different 
  //    screens and views in the application to reduce unnecessary data request
  // ==========================================
  var SharedData= PaperClub.SharedData = (function() {
    var clubs = new Clubs();

    return {
      getClubs: function() {
        return clubs;
      },
      getClub: function(id) {
        var club = clubs.get(id);
        if(!club) {
          club = new Club({id: id});
          clubs.add(club);
        }
        return club;
      } 
    };
  })();
  window.SharedData = SharedData;

  // ==========================================
  // Start application
  // =========================================
  var app = new App();

    
});
