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
          SharedData.currentClubId = clubId 
                                   = parseInt(clubId);
          that.switchScreen(that.getCachedScreen("club", clubId));
        },
        showPaper: function(paperId) {
          paperId = parseInt(paperId);
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
        }
        return clubScreen;
      }
      else if(name=="paper") {
        var paperScreen = this.cache.paperScreen[id];
        if(!paperScreen) {
          paperScreen = this.cache.paperScreen[id]
                      = new PaperScreen({
                          paperId: id
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
  var Screen = PaperClub.Screen = function(options) {

    Backbone.View.apply(this, [options]);
  }

  _.extend(Screen.prototype, Backbone.View.prototype, {
    visible: false,
    show: function() {
      if(this.visible)
        return;
      this.$el.appendTo("body").show();
      this.visible = true;

      this.trigger("show");
    },
    hide: function() {
      if(!this.visible)
        return;
      this.$el.detach().hide();      
      this.visible = false;

      this.trigger("hide");
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
      };
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
      var clubId = this.clubId = this.options.clubId;
      this.summaryView = new ClubScreenSummaryView({clubId: clubId});
      this.paperListView = new PaperListView({clubId: clubId});

      this.initEvents();

      this.uploader = new PaperUploader({clubId: this.clubId});

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
    },
    show: function() {
      Screen.prototype.show.apply(this);
      // Uploader must be initialized after DOM is ready
      window.uploader = this.uploader;
      this.uploader.init(); 
    }
  });

  var ClubScreenSummaryView = Backbone.View.extend({
    className: "section",
    template: _.template($("#club-screen-summary-template").html()),
    initialize: function() {
      this.clubId = this.options.clubId;
      this.club = SharedData.getClub(this.clubId); 

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
      this.$el.append(this.template());

      this.initEvents();

      this.papers = SharedData.getPapers();
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
                        id:  this.paper.get('id'),
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

  var PaperUploader = function(options) {
    var clubId = options.clubId;
    
    this.papers = SharedData.getPapers();

    var uploader = this.uploader = new plupload.Uploader({
      runtimes : 'html5',
      browse_button : 'paper-upload-btn',
//      container: 'uploader',
      max_file_size : '10mb',
      url : '/api/clubs/' + clubId + '/papers',
      multipart_params: {
      },
      filters : [
          {title : "PDF files", extensions : "pdf"}
      ]
    });   
  };

  _.extend(PaperUploader.prototype, {}, {
    _initialized: false,
    init: function() {
      if(this._initialized)
        return;

      this._initialized = true;

      var uploader = this.uploader,
          that     = this;

      uploader.init();
      uploader.bind('FilesAdded', function(up, files) {
        $.each(files, function(i, file) {
          uploader.start();
        });
      });
      uploader.bind('FileUploaded', function(up, file, result) {
        //var response = JSON.parse(result.response),
        //papers.create()
        that.papers.fetch();
      });
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
      var that = this;

      this.paperId = this.options.paperId;

      this.paper = SharedData.getPaper(this.paperId);
 
      this.paper.fetch({
        success: function() {
          that.viewport = new PsViewport({screen: that});

          that.pageNumber = new PsPageNumber({screen: that});
          that.toolbar = new PsToolbar({screen: that});

          that.render();  
        }
      });
    },
    render: function() {
      this.$el.empty()
              .append(this.pageNumber.render().$el)
              .append(this.toolbar.render().$el)
              .append(this.viewport.render().$el);
      return this;      
    }
  });

  var PsViewport = Backbone.View.extend({
    tagName: "ul",
    className: "r-viewport",
    currentPageNum: 1,
    initialize: function() {
      this.screen = this.options.screen;
      
      var that  = this,
          paper = this.paper = this.screen.paper,
          w     = parseInt(paper.get("width")),
          h     = parseInt(paper.get("height")),
          numPages = this.numPages = paper.get("num_pages"),
          pages = this.pages = new Array(numPages),
          W     = this.viewportWidth = 0.62 * $(window).width(),
          H     = W*h/w,
          z     = this.zoomFactor = 1; 
  
      this._loadCss();
      this.screen.on("show", this._loadCss, this);
      this.screen.on("hide", this._unloadCss, this);

      $.each(pages, function(i) {
        pages[i] = new PsPage({
          pageNum:  i+1, 
          width: W,
          height: H,
          viewport: that
        });
        that.$(".viewport-pages").append(pages[i].$el);
      });
      if(pages.length > 0) pages[0].onVisible();
      if(pages.length > 1) pages[1].onVisible();

      var scrolling = false, 
          lastScrollTime = Date.now(),
          scrollTimer = null;
        $(window).scroll(function() {
          // Start scrolling
          if(!scrolling) {
            scrolling = true;
            that.trigger("startScrolling");
          }

          // When scrolling
          var currentPageNum = that.decidePageNum();
          if(currentPageNum != that.currentPageNum) {
            that.currentPageNum = currentPageNum;
            that.trigger("changePage", currentPageNum);
          }

          // Use timer to decide when to redraw pages
          lastScrollTime = Date.now();
          if(scrollTimer) clearInterval(scrollTimer);
          scrollTimer = setInterval(function() {
            // When stop scrolling
            if (Date.now() - lastScrollTime > 450) {
              clearInterval(scrollTimer);
              // Redraw pages
              that.updatePages();
              // End scrolling
              that.trigger("endScrolling");
              scrolling =  false;
            }
          }, 200);
        });
    },
    decidePageNum: function() {
      var pages = this.pages,
          l     = pages.length,
          $w    = $(window),
          H     = $w.height(),
          st    = $w.scrollTop(),
          threshold = H - 50;

      for(var i = 0; i < l; ++i) {
        t = pages[i].$el.offset().top - st;
        if( t > threshold ) {
          break;
        }
      }
      return i;
    },
    updatePages: function() {
      var that = this, pages = this.pages,
          viewportHeight = $(window).height(),
          l = pages.length;
      
      // Find the first visible page
      for(var first = 0; first < l; ++first) {
        if(that.isPageVisible(pages[first], viewportHeight))
          break;
      }
      // Find the last visible page
      for(var last = l - 1; last >= 0; --last) {
        if(that.isPageVisible(pages[last], viewportHeight))
          break;
      }
      // Set invisible
      that.setVisibilities(first == 0 ? first : first-1, 
                           last == l - 1 ? last : last + 1, true);
      that.setVisibilities(0, first - 2, false);
      that.setVisibilities(last + 2, l-1, false);
    },
    isPageVisible: function(page, viewportHeight) {
      var st = $(window).scrollTop(),
          t = page.$el.offset().top -st,
          b = t + page.$el.height() ;
      var res = ( ! ( b < 0 || t >= viewportHeight ) );
      return res;
    },
    setVisibilities: function(from, to, visible) {
      if(visible)
        console.debug("visible: from="+from+", to="+to)        

      for(var i = from; i <= to; ++i) {
        if(visible) {
          this.pages[i].onVisible(); 
        }
        else { 
          this.pages[i].onInvisible(); 
        }
      }
    },
    render: function() {
      var $this = this.$el,
          pages = this.pages;

      $.each(pages, function(i) {
        $this.append(pages[i].render().$el);
      });

      return this;
    },
    zoomIn: function() {
      this._zoom(this.zoomFactor + 0.1);      
    },
    zoomOut: function() {
      this._zoom(this.zoomFactor - 0.1);
    },
    _zoom: function(zoomFactor) {
      if(zoomFactor > 3 || zoomFactor < 0.4)
        return;

      this.zoomFactor = zoomFactor;
      
      var pages = this.pages,
          that  = this;
      $.each(pages, function(i) {
        pages[i].zoom(that.zoomFactor);
      });
      $(window).scrollTop($(window).scrollTop()*zoomFactor);
    },
    _loadCss: function() {
      var allCssUrl = ["/api/fulltext", this.paper.id, "all.css"].join("/");

      this._unloadCss();

      // Add the new one
      $("<link id=\"fulltext-css\">").appendTo("head").attr({
        rel: "stylesheet",
        type: "text/css",
        href: allCssUrl
      });
    },
    _unloadCss: function() {
      // Remove the all one(if exists)
      $("#fulltext-css").remove();
    }
  });

  var PsPage = Backbone.View.extend({
    tagName: "li",
    className: "r-viewport-page",
    state: "blank",
    nowVisible: false,
    states: {
      blank: {
        onVisible: function() {
          this.setState("loading");
        }
      },
      loading: {
        transition: function(previousState) {
          this.states.loading._doLoading.apply(this);
        },
        _doLoading: function() {
          if(this.pageContent) return;

          var that = this,
              pageHtmlUrl = ['/api/fulltext', 
                             this.viewport.paper.id, 
                             'pages', 
                             this.pageNum].join("/");
          $.ajax({
            url: pageHtmlUrl,
            data: null, 
            context: that,
            dataType: "html"
          })
          .done(this.states.loading._onSuccess)
          .fail(this.states.loading._onFail);
        },
        _onSuccess: function(pageContent) {
          this.pageContent = pageContent;

          if(this.nowVisible) 
            this.setState("viewable");
          else
            this.setState("hidden");
        },
        _onFail: function() {
          if(this.nowVisible) {
            var that = this;
            setTimeout(function(){
              this.states.loading._doLoading.apply(this);
            }, 1000);
          }
          else
            this.setState("blank");
        }
      },
      viewable: {
        transition: function(previousState) {
          if(!this.$pageContent) {
            var $pc = this.$pageContent = $(this.pageContent),
                ow  = $pc.css('width'),
                oh  = $pc.css('height');
            this.orignalWidth   = parseInt(ow.slice(0, ow.length-2));
            this.orignalHeight  = parseInt(oh.slice(0, oh.length-2));
            $pc.css({scale: this.zoomFactor * this.width/this.orignalWidth})
            this.$el.append(this.$pageContent);
          }
          else {
            this.$pageContent.show();
          }
        },
        onInvisible: function() {
          this.setState("hidden")
        }
      },
      hidden: {
        transition: function(previousState) {
          if(this.$pageContent)
            this.$pageContent.hide();
        },
        onVisible: function() {
          this.setState("viewable");
        }
      }
    },
    initialize: function() {
      this.pageNum  = this.options.pageNum;
      this.width    = this.options.width;
      this.height   = this.options.height;
      this.viewport = this.options.viewport;
      this.zoomFactor = 1.0;

      // Init blank state
      this.setState("blank");

      var that = this;
      this.viewport.screen.on("hide", function() {
        if(this.state == "viewable") that.setState("hidden");
      });
    },
    setState: function(state) {
      var previousState = this.state;
      this.state = state; 
      var transition = this.states[state].transition;
      if(transition) transition.apply(this, [previousState]);
    },
    onVisible: function() {
      this.nowVisible = true;
      var onVisible = this.states[this.state].onVisible;
      if(onVisible) onVisible.apply(this, arguments);
    },
    onInvisible: function() {
      this.nowVisible = false;
      var onInvisible = this.states[this.state].onInvisible;
      if(onInvisible) onInvisible.apply(this, arguments);
    },
    zoom: function(zoomFactor) {
      this.zoomFactor = zoomFactor;

      this.$el.width(this.width * this.zoomFactor)
              .height(this.height * this.zoomFactor);
      if(this.$pageContent)
        this.$pageContent.css({scale: zoomFactor * this.width / this.orignalWidth});
    },
    render: function() {
      this.$el.empty()
              .width(this.width+"px")
              .height(this.height+"px");
      return this;        
    }
  });

  var PsToolbar = Backbone.View.extend({
    className: "r-footer active bgwhite shadow0210 tc",
    template: _.template($("#paper-screen-toolbar-template").html()),
    events: {
      "click a.zoomIn": "zoomIn",
      "click a.zoomOut": "zoomOut"
    },
    visible: true,
    initialize: function() {
      this.screen = this.options.screen;
      this.paper = this.screen.paper;

      this.paper.on('change', this.render, this);

      var that = this;
      setTimeout(function() {
        that.hide();
      }, 1000);

      this.initEvents();
    },
    initEvents: function() {          
      var that = this;

      // Keep window's width & height
      var W = $(window).width(),
          H = $(window).height();
      $(window).resize(function() {
        W = $(window).width();
        H = $(window).height();
      });

      // Monitor slideArea
      var l = 48, r = 48, h = 36,
          timer = null;
      window.that =that;
      $(window).mousemove(function(e) {
        var x = e.clientX,
            y = e.clientY;
        console.debug("W="+W+";H="+H+";l="+l+";r="+r+";h="+h);
        console.debug("x="+x+";y="+y);
        // Invisible => visible
        if(l < x && x < W - r &&
           H - h <= y && y <= H) {
          that.show();
          console.debug("yes");
        }
        // Visible => invisible
        else{
          console.debug("no");
          that.hide();
        }  
      });
    },
    show: function() {
      if(this.visible) return;

      this.visible = true;
      this.$el.addClass("active");
    },
    hide: function() {
      if(!this.visible) return;

      this.visible = false;
      this.$el.removeClass("active");
    },
    render: function() {
      var paper = this.screen.paper;

      this.$el.empty()
              .append(this.template({
                        club_id: paper.get("club_id"),
                        title: paper.get('title'),
                        download_url: "/api/fulltext/" + paper.id + "/download"
                      }));
      return this;
    },
    zoomIn: function() {
      this.screen.viewport.zoomIn();
    },
    zoomOut: function() {
      this.screen.viewport.zoomOut();
    }
  });

  var PsPageNumber = Backbone.View.extend({
    pageNum: 1,
    className: "r-pagination bgwhite shadow024 tc fs30 fw-bold fs-ita color-blue font-c",
    initialize: function() {
      this.screen = this.options.screen;

      var viewport = this.screen.viewport;
      viewport.on('changePage',       this.setPageNumber, this)
              .on('startScrolling',   this.show, this)
              .on('endScrolling',     this.hide, this);
    },
    setPageNumber: function(pageNum) {
      this.pageNum = pageNum;
      this.$el.text(pageNum);
    },
    render: function() {
      this.$el.text(this.pageNum);
      return this;        
    },
    show: function() {
      this.$el.show();
    },
    hide: function() {
      this.$el.hide();
    }
  }); 

  // ==========================================
  //    SharedStore
  //
  //    All collections and models in SharedStore are shared among different 
  //    screens and views in the application to reduce unnecessary data request
  // ==========================================
  var SharedData= PaperClub.SharedData = (function() {
    var _clubs = new Clubs(),
        _papersOfClub = {},
        _data = {
          currentClubId: null,
          getClubs: function() {
            return _clubs;
          },
          getClub: function(id) {
            var club = _clubs.get(id);
            if(!club) {
              club = new Club({id: id});
              _clubs.add(club);
            }
            return club;
          },
          getPapers: function() {
            var currentClubId = _data.currentClubId;
            if(currentClubId != null) {
              var papers = _papersOfClub[currentClubId];
              if(!papers) {
                papers = _papersOfClub[currentClubId] 
                       = new Papers(null, {clubId: currentClubId});
              }
              return papers;
            }
            return null;
          },
          getPaper: function(paperId) {
            var papers = _data.getPapers(),
                paper = null;
            if(papers)
              paper = papers.get(paperId);
            if(!paper)
              paper = new Paper({id: paperId});
            return paper;
          }
        };
    return _data;
  })();
  window.SharedData = SharedData;

  // ==========================================
  // Start application
  // =========================================
  var app = new App();

    
});
