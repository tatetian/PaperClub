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
    },
    onWindowEvent: function(eventName, callback, shown) {
      var that = this,
          namespacedEvent = eventName + '.' + that.cid;
          
      this.on('show', function() {
        $(window).bind(namespacedEvent, callback);

        // Call resize's callback when showing
        if(namespacedEvent.indexOf('resize')==0 || 
           namespacedEvent.indexOf('scroll')==0)
          callback();
      })  .on('hide', function() {
        $(window).unbind(namespacedEvent);
      });

      if(shown) 
        $(window).bind(namespacedEvent, callback);
   }
  });
    
  Screen.extend = Backbone.View.extend;

  var TwoColumnScreen = function(options) {
    Screen.apply(this, [options]);

    var that = this;
    // White area not too short
    this.onWindowEvent('resize', function() { 
      var H = $(window).height() - 24*2;

      that.$el.css('min-height', H);

      that.$(".p-sidebar")    .css('min-height', H);
      that.$(".p-paper-list") .css('min-height', H);

      $(window).scroll();
    }, true);
    // Smart float
    var $sidebarMain = that.$(".p-sidebar > .main"),
        $backBtn     = that.$(".p-sidebar > .p-btn-back"),
        margin       = 24,
        threshold    = 36;
    this.onWindowEvent('scroll', function() {
      var $w  = $(window),
          T   = $w.scrollTop(),
          h   = $w.height(),
          H   = $("body").height(),
          b   = H - h - T,
          L   = $w.scrollLeft();
      // Adjust sidebar upper part
      if( T > threshold ) {
        $sidebarMain.css({
          position: 'fixed',
          top: margin
        });
      }
      else {
        $sidebarMain.css({'position': 'static'});
      } 
      // Adjust sidebar lower part
      $backBtn.css({
        bottom: (b < margin ? 60 - b : 36),
        left: 60 - L 
      });
    }, true);
  }

  _.extend(TwoColumnScreen.prototype, Screen.prototype, {});

  TwoColumnScreen.extend = Screen.extend;

  // ==========================================
  //    AllClubsScreen
  // ==========================================
  var AllClubsScreen = PaperClub.AllClubsScreen = TwoColumnScreen.extend({
    className: "p-page-content shadow024 bgwhite",
    initialize: function() {
      this.render();

      this.newClubDialoge = new NewClubDialoge({screen: this});

      this.clubs = SharedData.getClubs();
      this.clubs.on('add', this.onAddOne, this)
                .on('reset', this.onAddAll, this);

      this.initEvents();
    },
    template: _.template($("#clubs-screen-template").html()),
    initEvents: function() {
      var that = this;
      this.$(".c-btn-newclub").click(function(e) {
        that.onNewClub();
        e.preventDefault();
      });
      this.$("#signout-btn").click(function(e) {
        $.ajax({
          url:"/api/signout",
          type: "delete",
          success: function() {
            location.href = "/";
          }
        });
        e.preventDefault();
      });

      this.on('show', function() {
        that.load();
      });
    },
    load: function(showLoading) {
      var that = this;

      // Show loading for the first time
      if(this.clubs.size() == 0 || showLoading) {
        this.$("ul").empty();
        this.$el.addClass('loading');
        $(window).scroll();
      }
      this.clubs.fetch({
        success: function() {
          that.$el.removeClass('loading');
          $(window).scroll();
        },
        error: function() {
          that.$el.removeClass('loading');
          $(window).scroll();
        }
      });
    },
    render: function() {
      this.$el.empty()
              .append(this.template()); 
      return this;      
    },
    onNewClub: function() {
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
    template: _.template($("#new-club-dialoge-data-template").html()),
    events: {
      "click .c-btn-creatclub": "onOK",
      "click .c-btn-cancelclub": "onCancel"
    },
    initialize: function() {
      this.$el.append($($("#new-club-dialoge-template").html()));

      var that = this,
          screen = this.screen = this.options.screen;
      screen.onWindowEvent('resize', function() {
        // Size of new club dialog
        var whtml = $(window).width();
        var wst_c = (whtml-48-255-18-36)*0.5;
        that.$('.m-m-container').css({"width":wst_c+88,"height":260});
      }); 
    },
    render: function() {
      return this;
    },
    show: function() {
      this.$el.appendTo($("body")).show();

      this.model = new Club();

      this.$(".m-m-content").empty().prepend(this.template(this.model.toJSON()));
    },
    hide: function() {
      this.$el.detach().hide();
    },
    onOK: function(e) {
      var screen = this.screen;
      this.model.set(this.retrieveValues())
                .save(null, {
                  success: function() {
                    screen.load(true);
                  }
                });  
      this.hide();

      e.preventDefault();
    },
    onCancel: function(e) {
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
    className: "font-c cf mb40 ",
    template: _.template($("#joined-club-template").html()),
    initialize: function() {
      this.club = this.options.club;
    },
    render: function() {
      var json = this.club.toJSON();
      json.avatar_urls = json.users.map(function(u) {
                            return u.avatar_url || "";
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
  var OneClubScreen = PaperClub.OneClubScreen = TwoColumnScreen.extend({
    className: "p-page-content shadow024 bgwhite",
    template: _.template($("#club-screen-template").html()),
    initialize: function() {
      var clubId = this.clubId = this.options.clubId;
      
      this.render(); 
    },
    render: function() {
      this.$el.empty()
              .append(this.template());

      this.summaryView = new ClubScreenSummaryView({clubId: this.clubId});
      this.paperListView = new PaperListView({clubId: this.clubId,
                                              screen: this,
                                              el: this.$(".p-paper-list")});
      this.paperListView.render();
      this.uploader = new PaperUploader({clubId: this.clubId, screen: this});


      this.$el.find(".p-sidebar > .main").prepend(this.summaryView.render().$el);
      this.$el.find(".upload-btn-wrapper").append(this.uploader.render().$el);
              
      return this;      
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
    template: _.template($("#club-screen-paper-list").html()),
    lastFetchParams: null,
    /* States: init, loading, part_loaded, loading_more, all_loaded, error */
    state: "init", 
    // TODO: set-to-1 bug
    PAGE_ITEMS: 10,
    initialize: function() {
      this.screen = this.options.screen;

      this.$el.append(this.template());

      this.papers = SharedData.getPapers();
      this.papers.on('add', this._onAddOne, this)
                 .on('reset', this._onAddAll, this);
    
      this.$more = $('<div class="mb15 cleanfloat loading" style="width: 100%;">' +
                     '&nbsp;<br/>&nbsp;</div>');
      this.tempPapers = new Papers(null, {clubId: this.options.clubId});
      this.tempPapers.on('reset', this._loadData, this);
      
      this.initEvents();
    },
    _loadData: function() {
      var items = this.tempPapers,
          hasMore = false;

      while(items.size() > this.PAGE_ITEMS) {
        items.pop();
        hasMore = true;
      }
      items.hasMore = hasMore;
      this.papers.add(items.models);
    },
    initEvents: function() {
      var that = this;

      var lastKeywords = "";
      // Init search events
      function _doSearch(e) {
        var keywords = $(this).val();
        lastKeywords = keywords;
        that.search(keywords);
        e.preventDefault();
      }
      this.$(".paper-search").on("change", _doSearch);
      // Listen clear event
      this.$(".paper-search").on("keyup", function() {
        var keywords = $(this).val();
        if(keywords == "" && lastKeywords != "") {
          lastKeywords = "";
          that.search(); 
        }
      });
      // Init more events
      this.screen.onWindowEvent('scroll', function() {
        var h = $(window).height(),
            t = $(window).scrollTop(),
            H = $("body").height(),
            b = H - h - t;
        if(b < 50) {
          that.more()
        }
      });
    },
    search: function(keywords, tag, user_id) {
      var that = this;

      this.state = "loading";

      var data = {offset: 0, limit: this.PAGE_ITEMS+1};
      if(keywords) data.keywords = $.trim(keywords);
      if(tag) data.tag = tag;
      if(user_id) data.user_id = user_id;

      this.lastFetchParams = data;

      this.papers.reset([]);
      this.$el.addClass('loading');

      var items = this.tempPapers;
      items.hasMore = true;
      items.fetch({
        data: data,
        success: function() {
          if(items.hasMore)
            that.state = "part_loaded";
          else
            that.state = "all_loaded";

          that.$el.removeClass('loading');
          $(window).scroll();
        },
        error: function() {
          that.state = "error";
          // TODO: show error message
          that.$el.removeClass('loading');
        }
      });
    },
    more: function() {
      if(this.state != "part_loaded") return;

      this.state = "loading_more";

      // Show loading
      this.$("ul").append(this.$more);

      var items = this.tempPapers,
          that  = this;

      this.lastFetchParams.offset += this.PAGE_ITEMS;
      setTimeout(function(){items.fetch({
        data: that.lastFetchParams,
        beforeReset: function() {
          that.$more.detach();
        },
        success: function() {
          if(items.hasMore)
            that.state = "part_loaded";
          else
            that.state = "all_loaded";
          $(window).scroll();
        },
        error: function() {
          that.state = "error";
          // TODO: show error message
          that.$more.detach();
        }
      })}, 600);
    },
    render: function() {
      this.search();
      return this; 
    },
    _onAddOne: function(paper, that, options) {
      var paperView = new PaperItemView({paper: paper});
      this.$("ul").append(paperView.render().$el)
    },
    _onAddAll: function() {
      this.$("ul").empty();
      this.papers.each(this._onAddOne, this);      
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
      var news = this.paper.get('news');
      if(news) news.time = this.formatDate(news.time);

      this.$el.empty()
              .append(this.template({
                        //this.paper.toJSON()
                        id:  this.paper.get('id'),
                        title: this.paper.get('title'),
                        num_favs: 0,
                        num_reads: 0,
                        num_notes: 0,
                        tags: this.paper.get('tags'),
                        news: news
                      }));
      return this;       
    },
    formatDate: function(date) {
      if(!date) return "";

      var d = new Date(Date.parse(date)),
          n = new Date();   // now

      if( ( d.getDate()  == n.getDate()  ) &&
          ( d.getMonth() == n.getMonth() ) && 
          ( d.getYear()  == n.getYear()  ) ) {
        return d.toLocaleTimeString();
      }
      else {
        return d.toDateString();
      }
    }
  });

  var PaperUploader = Backbone.View.extend({
    tagName: "a",
    id: "paper-upload-btn",
    initialize: function() {
      var that = this, 
          clubId = this.options.clubId;
      
      this.screen = this.options.screen;
      this.papers = SharedData.getPapers();

      var uploader = this.uploader = new plupload.Uploader({
        runtimes : 'html5',
        browse_button : 'paper-upload-btn',
        max_file_size : '10mb',
        url : '/api/clubs/' + clubId + '/papers',
        container: 'uploaders-container',
        multipart_params: {
        },
        filters : [
            {title : "PDF files", extensions : "pdf"}
        ]
      });   
    
      // Init events after the required DOM element is ready  
      var firstTime = true;
      this.screen.on("show", function() {
        if(!firstTime)
          return;

        firstTime = false;
        that._initEvents();
      });      
    },
    _template: _.template($("#paper-upload-btn-template").html()),
    _state: {
      uploading: false,
      progress: 0,
      num_files: 0,
      current: 0,
      errors: 0
    },
    _initEvents: function() {
      var that     = this,
          uploader = this.uploader,
          state    = this._state;

        
      uploader.init();
      uploader.bind('FilesAdded', function(up, files) {
        //$.each(files, function(i, file) {
        //});
        // Disable the btn
        uploader.disableBrowse(true);

        state.uploading = true;
        state.progress = 0;
        state.num_files = files.length;
        state.current = 0;
        state.errors = 0;

        that.render();

        uploader.start();
      });
      uploader.bind('UploadProgress', function(up, file) {
        state.progress = Math.round( 
          file.percent / state.num_files + 
          ( state.current > 0 ? (state.current - 1) / state.num_files : 0 ) * 100 );

        that.render();
      });
      uploader.bind('FileUploaded', function(up, file, result) {
        that.papers.fetch();

        state.current ++;
        state.progress = Math.round(100 * state.current / state.num_files);
        if(state.current == state.num_files) {
          state.progress = 100; 
          uploader.disableBrowse(false);

          setTimeout(function() {
            state.uploading = false;
            that.render();
          }, state.errors > 0 ? 5000 : 1000);
        }
        that.render();
      });
      uploader.bind('Error', function() {
        state.current ++;
        state.errors ++;

        state.progress = Math.round(100 * state.current / state.num_files);
        if(state.current == state.num_files) {
          state.progress = 100; 
          uploader.disableBrowse(false);

          setTimeout(function() {
            state.uploading = false;
            that.render();
          }, state.errors > 0 ? 5000 : 1000); // Show error message long enough
        }
        that.render();
      });      
    },
    render: function() {
      this.$el.html(this._template(this._state));
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
      var that = this;

      this.paperId = this.options.paperId;

      this.paper = SharedData.getPaper(this.paperId);
 
      this.paper.fetch({
        success: function() {
          that.viewport = new PsViewport({screen: that});

          that.pageNumber = new PsPageNumber({screen: that});
          that.toolbar = new PsToolbar({screen: that});
     
   //       that.commentsPanel = new PsCommentsPanel({screen: that});
   //       that.detailsPanel  = new PsDetailsPanel({screen: that});

          that.render();  
        }
      });
    },
    render: function() {
      this.$el.empty()
              .append(this.pageNumber.render().$el)
              .append(this.toolbar.render().$el)
              .append(this.viewport.render().$el);
        //      .append(this.commentsPanel.render().$el)
//              .append(this.detailsPanel.render().$el);

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
          W     = this.viewportWidth = 0.65 * $(window).width(),
          H     = W*h/w,
          z     = this.zoomFactor = 1; 
  
      this._loadCss();
      this.screen.on("show", function() {
        this._loadCss();

        var that = this;
        setTimeout(function() {
          var pages = that.pages;

          if(pages.length > 0) pages[0].onVisible();
          if(pages.length > 1) pages[1].onVisible();
        }, 600);
      }, this);
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
      
      var pages = that.pages;
      if(pages.length > 0) pages[0].onVisible();
      if(pages.length > 1) pages[1].onVisible();

      this.initScrollEvents();
      this.initKeyboardEvents();
    },
    initScrollEvents: function() {
      var that = this,
          scrolling = false, 
          lastScrollTime = Date.now(),
          scrollTimer = null;
      
      this.screen.onWindowEvent('scroll', function() {
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
          if (Date.now() - lastScrollTime > 300) {
            clearInterval(scrollTimer);
            // Redraw pages
            that.updatePages();
            // End scrolling
            that.trigger("endScrolling");
            scrolling =  false;
          }
        }, 300);
      }, true);
    },
    initKeyboardEvents: function() {
      // Keyboard support:
      //  + and =    --> Zoom in
      //  -          --> Zoom out
      //  (0-9)+g    --> Go to page
      var that = this,
          keySeq = '';
      this.screen.onWindowEvent('keypress', function(e) {
        // Won't respond if CTRL is pressed
        if(e.ctrlKey) return;

        var code = e.which;
        switch(code) {
        case 61:   // =
          that.zoomIn();
          break;
        case 45:   // -
          that.zoomOut();
          break;
        case 103:    // g
          pageNum = parseInt(keySeq);
          if(!isNaN(pageNum)) {
            that.scrollToPage(pageNum); 
          }
          break;
        case 48: case 49: case 50: case 51: case 52:  // 0-4
        case 53: case 54: case 55: case 56: case 57:  // 5-9
          keySeq += (code-48);
          return;
        }

        keySeq = '';
      }, true);
    },
    scrollToPage: function(pageNum) {
      pageNum = Math.max(1, Math.min(pageNum, this.numPages));
      // Step 1. Find the top of page pageNum
      var pages = this.pages,
          page  = pages[pageNum-1],
          t     = page.$el.offset().top;
      // step 2. Scroll to the page
      $(window).scrollTop(t-13).scroll(); 
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
      var that        = this,
          allCssUrl   = ["/api/fulltext", this.paper.id, "all.css"].join("/"),
          isReadyUrl  = ["/api/fulltext", this.paper.id, "ready"].join("/"),
          tries       = 0,
          MAX_TRIES   = 35,
          timer       = null,
          timeout     = 500,
          timeDelta   = 250;

      that._unloadCss();

      function doLoadCss() {
        if(tries >= 2)
          $("#fulltext-css-"+(tries-2)).remove();

        $("<link id=\"fulltext-css-" + tries + "\" class=\"fulltext-css\">").appendTo("head").attr({
          rel: "stylesheet",
          type: "text/css",
          href: allCssUrl + "?tries=" + tries
        });
      };

      function checkCssComplete() {
        $.ajax({
          url: isReadyUrl + "?tries=" + tries,
          data: null, 
          context: that,
          dataType: "json"
        })
        .done(function(is_complete) {
          if(!is_complete && tries < MAX_TRIES) {
            timer = setTimeout(function() {
              tries++;
              checkCssComplete();
              doLoadCss();
            }, timeout);

            if(timeout <= 2000)
              timeout += timeDelta;
          }
          else {
            if(tries > 1)
              $("#fulltext-css-"+(tries-1)).remove();
          }
        })
        .fail(function() {
          timer = setTimeout(function() {
            checkCssComplete();
            doLoadCss();
          }, 5000);
        });
      }

      checkCssComplete();
      doLoadCss();

      this.on('hide', function() { if(timer) { clearTimer(timer); timer = null;} });
    },
    _unloadCss: function() {
      // Remove the all one(if exists)
      $(".fulltext-css").remove();
    }
  });

  var PsPage = Backbone.View.extend({
    tagName: "li",
    className: "r-viewport-page shadow024",
    state: "blank",
    nowVisible: false,
    tries: 0,
    states: {
      blank: {
        transition: function() {
        },
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
            url: pageHtmlUrl + "?tries=" + (this.tries++),
            data: null, 
            context: that,
            dataType: "html"
          })
          .done(this.states.loading._onSuccess)
          .fail(this.states.loading._onFail);

          this.$el.addClass('loading');
        },
        _onSuccess: function(pageContent) {
          this.pageContent = pageContent;

          this.$el.removeClass('loading');

          if(this.nowVisible) 
            this.setState("viewable");
          else
            this.setState("hidden");
        },
        _onFail: function() {
          if(this.nowVisible) {
            var that = this;
            setTimeout(function(){
              that.states.loading._doLoading.apply(that);
            }, 1000);
          }
          else {
            this.$el.removeClass('loading');
            this.setState("blank");
          }
        }
      },
      viewable: {
        transition: function(previousState) {
          if(!this.$pageContent) {
            var $pc = this.$pageContent = $(this.pageContent),
                $p  = $pc.find(".p"),
                ow  = $p.css('width'),
                oh  = $p.css('height');
            this.orignalWidth   = parseInt(ow.slice(0, ow.length-2));
            this.orignalHeight  = parseInt(oh.slice(0, oh.length-2));
            $p.css({scale: this.zoomFactor * this.width/this.orignalWidth})
            this.$el.css('background-color', 'white');
            this.$el.append(this.$pageContent);
          }
          this.$pageContent.show();
        },
        onInvisible: function() {
          this.setState("hidden")
        }
      },
      hidden: {
        transition: function(previousState) {
          if(this.$pageContent) {
            this.$pageContent.hide();
          }
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

      this.viewport.screen.on("hide", function() {
        if(this.state == "viewable") { 
           this.setState("hidden");
        }
        else if(this.state == "loading") {
          this.setState("blank");  
        }
      }, this);
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
        this.$pageContent.find(".p").css({scale: zoomFactor * this.width / this.orignalWidth});
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
      "click a.zoomIn": "clickZoomIn",
      "click a.zoomOut": "clickZoomOut",
      "click a.comments": "clickComments",
      "click a.details": "clickDetails"
    },
    autoHide: false,
    visible: true,
    initialize: function() {
      this.screen = this.options.screen;
      this.paper = this.screen.paper;

      this.paper.on('change', this.render, this);

      var that = this;

      // Autohide
      function onShow() {
        that.autoHide = false;
        that.show();
        setTimeout(function() { 
          that.autoHide = true;
          that.hide() 
        }, 3000);     
      }
      //this.screen.on('show', onShow);
      //onShow();

      //that.initMouseEvents();
      //
    },
    initMouseEvents: function() {          
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
      this.screen.onWindowEvent('mousemove', function(e) {
        if(!that.autoHide) return;

        var x = e.clientX,
            y = e.clientY;
        // Invisible => visible
        if(l < x && x < W - r &&
           H - h <= y && y <= H) {
          that.show();
        }
        // Visible => invisible
        else{
          that.hide();
        }  
      }, true);
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
    clickZoomIn: function() {
      this.screen.viewport.zoomIn();
    },
    clickZoomOut: function() {
      this.screen.viewport.zoomOut();
    },
    clickComments: function(e) {
      alert('click comments'); 
      e.preventDefault();
    },
    clickDetails: function(e) {
      alert('click details');
      e.preventDefault();
    }
  });

  var PsPageNumber = Backbone.View.extend({
    numPages: 0,
    pageNum: 1,
    className: "r-pagination bgwhite shadow024 tc fs20 fw-bold color-blue font-c",
    initialize: function() {
      this.screen = this.options.screen;

      this.numPages = this.screen.paper.get('num_pages');

      var viewport = this.screen.viewport;
      viewport.on('changePage',       this.setPageNumber, this)
              .on('startScrolling',   this.show, this)
              .on('endScrolling',     this.hide, this);
    },
    setPageNumber: function(pageNum) {
      this.pageNum = pageNum;
      this.$el.text(pageNum+" of "+this.numPages);
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

  var PsFloatPanel = function(options) {
    Backbone.View.apply(this, [options]);
  }

  _.extend(PsFloatPanel.prototype, Backbone.View.prototype, {
    className: "r-sidebar column-38 bgwhite shadow024 cf",
    initialize: function() {
      
    },
    render: function() {
      return this;
    },
    show: function() {
      this.$el.show();
    },
    hide: function() {
      this.$el.hide();
    }
  });

  PsFloatPanel.extend = Backbone.View.extend;

  var PsDetailsPanel = PsFloatPanel.extend({
  
  });

  var PsCommentsPanel = PsFloatPanel.extend({
  
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

  $("body").delegate("a.notYetImplemented", "click", function (e) {
    alert("Thank you for trying out PaperClub. This feature is coming soon.");
    e.preventDefault();
  });

  // ==========================================
  // Start application
  // =========================================
  var app = new App();
});
