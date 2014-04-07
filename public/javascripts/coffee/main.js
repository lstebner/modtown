// Generated by CoffeeScript 1.6.3
(function() {
  var Alert, Block, Calendar, ErrorAlert, Factory, Farm, FundsNotAvailableAlert, HUD, Housing, ModTownGame, Player, RenderedObject, Resident, StateManager, Street, Structure, Time, Timer, Town, WorldClock, _ref, _ref1, _ref2, _ref3,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Time = (function() {
    function Time() {}

    Time.now = function() {
      return (new Date()).getTime();
    };

    Time.in_millis = function(amount, of_what) {
      var conversions;
      conversions = {
        seconds: 1000,
        minutes: 60000,
        hours: 60000 * 60,
        days: 60000 * 60 * 24
      };
      conversions.s = conversions.seconds;
      conversions.m = conversions.minutes;
      conversions.h = conversions.hours;
      conversions.d = conversions.days;
      if (!_.has(conversions, of_what)) {
        return amount;
      }
      return conversions[of_what] * amount;
    };

    return Time;

  })();

  /* --------------------------------------------
       Begin Calendar.coffee
  --------------------------------------------
  */


  Calendar = (function() {
    function Calendar() {}

    Calendar.days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    Calendar.months = ['First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth', 'Nineth', 'Tenth', 'Eleventh', 'Twelvth', 'Thirteenth', 'Fourteenth', 'Fifteenth', 'Sixteenth'];

    Calendar.seasons = ['Spring', 'Summer', 'Fall', 'Winter'];

    Calendar.get_month = function(index) {
      if (index >= Calendar.months.length) {
        return false;
      }
      return Calendar.months[index];
    };

    Calendar.get_day = function(index) {
      if (index >= Calendar.days.length) {
        return false;
      }
      return Calendar.days[index];
    };

    Calendar.get_season = function(month) {
      return Calendar.seasons[Math.floor(month / 4) % Calendar.seasons.length];
    };

    return Calendar;

  })();

  World.Calendar = Calendar;

  /* --------------------------------------------
       Begin Timer.coffee
  --------------------------------------------
  */


  Timer = (function() {
    function Timer(duration, on_complete, on_tick) {
      this.duration = duration != null ? duration : 0;
      this.on_complete = on_complete != null ? on_complete : null;
      this.on_tick = on_tick != null ? on_tick : null;
      this.ticks = 0;
      this.timeout = null;
    }

    Timer.prototype.on = function(what, fn) {
      switch (what) {
        case 'on_tick':
          return this.on_tick = fn;
        case 'complete':
          return this.on_complete = fn;
      }
    };

    Timer.prototype.tick = function(repeat, tick_every) {
      var _this = this;
      if (repeat == null) {
        repeat = false;
      }
      if (tick_every == null) {
        tick_every = 1000;
      }
      if (this.complete()) {
        return;
      }
      if (typeof this.on_tick === "function") {
        this.on_tick(this.ticks);
      }
      if (repeat) {
        if (this.timeout) {
          clearTimeout(this.timeout);
        }
        this.timeout = setTimeout(function() {
          return _this.tick(true, tick_every);
        }, tick_every);
      }
      return this.update();
    };

    Timer.prototype.update = function() {
      this.ticks += 1;
      if (this.ticks > this.duration) {
        return this.finish();
      }
    };

    Timer.prototype.remaining = function() {
      return this.duration - this.ticks;
    };

    Timer.prototype.remaining_percent = function() {
      return this.ticks / this.duration;
    };

    Timer.prototype.complete = function() {
      return this.ticks > this.duration;
    };

    Timer.prototype.finish = function() {
      return typeof this.on_complete === "function" ? this.on_complete() : void 0;
    };

    Timer.prototype.reset = function(begin_ticking) {
      if (begin_ticking == null) {
        begin_ticking = false;
      }
      this.ticks = 0;
      if (begin_ticking) {
        return this.tick();
      }
    };

    return Timer;

  })();

  World.Timer = Timer;

  /* --------------------------------------------
       Begin WorldClock.coffee
  --------------------------------------------
  */


  WorldClock = (function() {
    WorldClock.double_time = false;

    WorldClock.max_seconds = 60;

    WorldClock.max_minutes = 60;

    WorldClock.max_hours = 10;

    WorldClock.max_days = 30;

    WorldClock.max_months = 16;

    WorldClock.seconds_in_minute = WorldClock.max_seconds;

    WorldClock.seconds_in_hour = WorldClock.seconds_in_minute * WorldClock.max_minutes;

    WorldClock.seconds_in_day = WorldClock.seconds_in_hour * WorldClock.max_hours;

    WorldClock.seconds_in_month = WorldClock.seconds_in_day * WorldClock.max_days;

    WorldClock.seconds_in_year = WorldClock.seconds_in_month * WorldClock.max_months;

    WorldClock.get_duration = function(amount, of_what) {
      var in_seconds;
      if (of_what == null) {
        of_what = 'seconds';
      }
      in_seconds = 0;
      switch (of_what) {
        case 'seconds' || 's':
          in_seconds = amount;
          break;
        case 'minutes' || 'm':
          in_seconds = amount * WorldClock.seconds_in_minute;
          break;
        case 'hours' || 'h':
          in_seconds = amount * WorldClock.seconds_in_hour;
          break;
        case 'days' || 'd':
          in_seconds = amount * WorldClock.seconds_in_day;
          break;
        case 'months' || 'mo':
          in_seconds = amount * WorldClock.seconds_in_month;
          break;
        case 'years' || 'y':
          in_seconds = amount * WorldClock.seconds_in_year;
      }
      return in_seconds;
    };

    function WorldClock() {
      this.since_epoch = 0;
      this.second = 0;
      this.minute = 0;
      this.hour = 0;
      this.day = 0;
      this.month = 0;
      this.year = 0;
      this.timeout = null;
      this.timers = [];
    }

    WorldClock.prototype.tick = function(set_timeout) {
      var onetick,
        _this = this;
      if (set_timeout == null) {
        set_timeout = true;
      }
      this.update();
      if (set_timeout) {
        if (this.timeout) {
          clearTimeout(this.timeout);
        }
        onetick = WorldClock.double_time ? 100 : 1000;
        return this.timeout = setTimeout(function() {
          return _this.tick();
        }, onetick);
      }
    };

    WorldClock.prototype.sync = function() {};

    WorldClock.prototype.update = function() {
      this.since_epoch += 1;
      if (this.since_epoch < WorldClock.max_seconds) {
        this.second = this.since_epoch;
      } else {
        this.second = this.since_epoch % WorldClock.max_seconds;
      }
      this.minute = this.since_epoch / WorldClock.seconds_in_minute % WorldClock.max_minutes;
      this.hour = this.since_epoch / WorldClock.seconds_in_hour % WorldClock.max_hours;
      this.day = Math.floor(this.since_epoch / WorldClock.seconds_in_day);
      this.month = Math.floor(this.since_epoch / WorldClock.seconds_in_month);
      this.year = Math.floor(this.since_epoch / WorldClock.seconds_in_year);
      return this.update_timers();
    };

    WorldClock.prototype.update_timers = function() {
      var timer, _i, _len, _ref, _results;
      _ref = this.timers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        timer = _ref[_i];
        _results.push(timer.tick());
      }
      return _results;
    };

    WorldClock.prototype.now = function() {
      return this.get_time();
    };

    WorldClock.prototype.get_time = function(format) {
      if (format == null) {
        format = null;
      }
      if (!format) {
        return this.since_epoch;
      }
      format = format.replace('h', this.get_hours(true));
      format = format.replace('m', this.get_minutes(true));
      format = format.replace('s', this.get_seconds(true));
      format = format.replace('d', this.get_day());
      format = format.replace('y', this.get_year());
      format = format.replace('mo', this.get_month());
      return format;
    };

    WorldClock.prototype.get_hours = function(format) {
      var h;
      if (format == null) {
        format = false;
      }
      h = Math.floor(this.hour);
      if (format) {
        if (h < 10) {
          return '0' + h.toString();
        } else {
          return h.toString();
        }
      } else {
        return h;
      }
    };

    WorldClock.prototype.get_minutes = function(format) {
      var m;
      if (format == null) {
        format = false;
      }
      m = Math.floor(this.minute);
      if (format) {
        if (m < 10) {
          return '0' + m.toString();
        } else {
          return m.toString();
        }
      } else {
        return m;
      }
    };

    WorldClock.prototype.get_seconds = function(format) {
      var s;
      if (format == null) {
        format = false;
      }
      s = Math.floor(this.second);
      if (format) {
        if (s < 10) {
          return '0' + s.toString();
        } else {
          return s.toString();
        }
      } else {
        return this.second;
      }
    };

    WorldClock.prototype.get_day = function() {
      return Calendar.get_day(this.day);
    };

    WorldClock.prototype.get_year = function() {
      return this.year + 1;
    };

    WorldClock.prototype.get_month = function() {
      return Calendar.get_month(this.month);
    };

    WorldClock.prototype.create_timer = function(duration, on_complete) {
      var new_timer;
      if (duration == null) {
        duration = 0;
      }
      if (on_complete == null) {
        on_complete = null;
      }
      new_timer = new Timer(duration, on_complete);
      this.timers.push(new_timer);
      return new_timer;
    };

    return WorldClock;

  })();

  World.WorldClock = WorldClock;

  /* --------------------------------------------
       Begin RenderedObject.coffee
  --------------------------------------------
  */


  RenderedObject = (function() {
    function RenderedObject(container, opts) {
      if (opts == null) {
        opts = {};
      }
      this.container = $(container);
      this.tmpl = this.set_template(this.template_id());
      this.rendered = false;
      this.view_data = {};
      this.set_opts(opts);
      this.name = this.opts.name != null ? this.opts.name : '';
      this.id = this.opts.id != null ? this.opts.id : -1;
      this.setup_events();
      if (this.opts.render) {
        this.render();
      }
    }

    RenderedObject.prototype.change_state = function(new_state) {
      return this.state.change_state(new_state);
    };

    RenderedObject.prototype.default_opts = function() {
      return {
        id: 0,
        name: '',
        render: false
      };
    };

    RenderedObject.prototype.set_opts = function(opts) {
      if (opts == null) {
        opts = {};
      }
      return this.opts = _.extend(this.default_opts(), opts);
    };

    RenderedObject.prototype.template_id = function() {
      return null;
    };

    RenderedObject.prototype.set_template = function(tmpl_id) {
      var new_tmpl;
      if (!tmpl_id) {
        return null;
      }
      new_tmpl = _.template($(tmpl_id).html());
      if (!new_tmpl) {
        return;
      }
      return this.tmpl = new_tmpl;
    };

    RenderedObject.prototype.get_view_data = function() {
      return {};
    };

    RenderedObject.prototype.set_view_data = function(key, val) {
      return this.view_data[key] = val;
    };

    RenderedObject.prototype.clear_view_data = function() {
      return this.view_data = [];
    };

    RenderedObject.prototype.setup_events = function() {
      var _this = this;
      return this.container.on('click', function(e) {
        return e.preventDefault();
      });
    };

    RenderedObject.prototype.render = function(force) {
      if (force == null) {
        force = false;
      }
      if ((this.rendered && !force) || !this.tmpl) {
        return;
      }
      this.container.empty();
      this.container.html(this.tmpl(_.extend(this.view_data, this.get_view_data())));
      return this.rendered = true;
    };

    return RenderedObject;

  })();

  /* --------------------------------------------
       Begin Alert.coffee
  --------------------------------------------
  */


  Alert = (function() {
    function Alert(message, type) {
      this.message = message != null ? message : '';
      this.type = type != null ? type : 'status';
      this.tmpl = _.template($('#alert-template').html());
      this.dismissed = false;
      this.render();
      this.setup_events();
    }

    Alert.prototype.setup_events = function() {
      var _this = this;
      return this.container.on('click', function(e) {
        var $el;
        e.preventDefault();
        $el = $(e.target);
        switch ($el.data('action')) {
          case 'dismiss':
            return _this.dismiss();
        }
      });
    };

    Alert.prototype.dismiss = function() {
      if (this.dismissed) {
        return;
      }
      this.dismissed = true;
      return this.container.fadeOut(function() {
        return $(this).remove();
      });
    };

    Alert.prototype.show = function() {
      return this.container.fadeIn();
    };

    Alert.prototype.render = function() {
      var $alert, data;
      data = {
        message: this.message,
        type: this.type
      };
      $alert = $(this.tmpl(data));
      this.container = $alert;
      $('body').append(this.container);
      return this.show();
    };

    return Alert;

  })();

  World.Alert = Alert;

  ErrorAlert = (function(_super) {
    __extends(ErrorAlert, _super);

    function ErrorAlert(message, type) {
      var _this = this;
      this.message = message != null ? message : '';
      this.type = type != null ? type : 'error';
      ErrorAlert.__super__.constructor.call(this, this.message, this.type);
      setTimeout(function() {
        return _this.dismiss();
      }, 1000 * 30);
    }

    return ErrorAlert;

  })(Alert);

  World.Alert.Error = ErrorAlert;

  FundsNotAvailableAlert = (function(_super) {
    __extends(FundsNotAvailableAlert, _super);

    function FundsNotAvailableAlert(message) {
      this.message = message != null ? message : 'Funds not available';
      FundsNotAvailableAlert.__super__.constructor.call(this, this.message);
    }

    return FundsNotAvailableAlert;

  })(ErrorAlert);

  /* --------------------------------------------
       Begin HUD.coffee
  --------------------------------------------
  */


  HUD = (function(_super) {
    __extends(HUD, _super);

    function HUD() {
      _ref = HUD.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    HUD.prototype.template_id = function() {
      return '#hud-template';
    };

    HUD.prototype.update = function(view_data) {
      this.view_data = view_data != null ? view_data : {};
    };

    HUD.prototype.setup_events = function() {
      var _this = this;
      return this.container.on('click', '.btn', function(e) {
        return _this.container.trigger('btn_pressed', $(e.target).data('action'));
      });
    };

    return HUD;

  })(RenderedObject);

  /* --------------------------------------------
       Begin StateManager.coffee
  --------------------------------------------
  */


  StateManager = (function() {
    function StateManager(state) {
      if (state == null) {
        state = '';
      }
      this.current_state = state;
      this.next_state = '';
      this.previous_state = '';
      this.bindings = {};
      this.history = [];
    }

    StateManager.prototype.current = function() {
      return this.current_state;
    };

    StateManager.prototype.on = function(event_name, fn, overwrite) {
      if (overwrite == null) {
        overwrite = false;
      }
      if (!_.has(this.bindings, event_name) || overwrite) {
        this.bindings[event_name] = [];
      }
      return this.bindings[event_name].push(fn);
    };

    StateManager.prototype.change_state = function(new_state) {
      if (new_state == null) {
        new_state = '';
      }
      this.next_state = new_state;
      return this.record_history('next');
    };

    StateManager.prototype.trigger = function(event_name, data) {
      var fn, _i, _len, _ref1, _results;
      if (data == null) {
        data = null;
      }
      if (!_.has(this.bindings, event_name)) {
        return;
      }
      _ref1 = this.bindings[event_name];
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        fn = _ref1[_i];
        _results.push(fn.apply(this, data != null));
      }
      return _results;
    };

    StateManager.prototype.record_history = function(type) {
      if (type == null) {
        type = 'changed';
      }
      switch (type) {
        case 'changed':
          return this.history.push({
            the_time: (new Date()).getTime(),
            current_state: this.current_state,
            previous_state: this.previous_state
          });
        case 'next':
          return this.history.push({
            the_time: (new Date()).getTime(),
            current_state: this.current_state,
            next_state: this.next_state
          });
      }
    };

    StateManager.prototype.update = function() {
      if (_.isEmpty(this.next_state)) {
        return;
      }
      this.previous_state = this.current_state;
      this.current_state = this.next_state;
      this.next_state = '';
      this.trigger('state_changed', [this.current_state, this.previous_state]);
      return this.record_history('changed');
    };

    return StateManager;

  })();

  /* --------------------------------------------
       Begin Town.coffee
  --------------------------------------------
  */


  Town = (function(_super) {
    __extends(Town, _super);

    Town.costs = {
      street: 100
    };

    Town.prototype.default_opts = function() {
      return _.extend({
        balance: 0
      }, Town.__super__.default_opts.apply(this, arguments));
    };

    function Town() {
      Town.__super__.constructor.apply(this, arguments);
      this.street_tmpl = _.template($('#street-template').html());
      this.location = [0, 0];
      this.time = 0;
      this.day = 0;
      this.year = 0;
      this.balance = this.opts.balance;
      this.spent = 0;
      this.next_street_id = 0;
      this.next_resident_id = 0;
      this.streets = [];
      this.street_ids_to_index = {};
      this.residents = [];
      this.resident_ids_to_index = {};
      this.blocks = [];
      this.block_ids_to_index = {};
      this.structures = [];
      this.structure_ids_to_index = {};
    }

    Town.prototype.template_id = function() {
      return '#town-template';
    };

    Town.prototype.render = function() {
      Town.__super__.render.apply(this, arguments);
      return this.render_streets();
    };

    Town.prototype.update = function() {
      var s, _i, _len, _ref1, _results;
      _ref1 = this.streets;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        s = _ref1[_i];
        _results.push(s.update());
      }
      return _results;
    };

    Town.prototype._street_id = function() {
      return this.next_street_id += 1;
    };

    Town.prototype._street_props = function(props) {
      if (props == null) {
        props = {};
      }
      return _.extend({
        id: this._street_id(),
        name: 'One Street'
      }, props);
    };

    Town.prototype.create_street = function(props) {
      var $new_street, new_street;
      if (props == null) {
        props = {};
      }
      if (!this.funds_available(Town.costs.street)) {
        new FundsNotAvailableAlert();
        throw 'Funds not available';
        return false;
      }
      this.spend_funds(Town.costs.street);
      props = this._street_props(props);
      $new_street = $(this.street_tmpl({
        id: props.id
      }));
      this.container.find('.streets').append($new_street);
      new_street = new Street(this.container.find(".street[data-id=" + props.id + "]"), props);
      this.streets.push(new_street);
      return this.street_ids_to_index[new_street.id] = this.streets.length - 1;
    };

    Town.prototype.create_block = function(street_id, props) {
      var new_block, street, street_idx;
      if (props == null) {
        props = {};
      }
      street_idx = this.street_ids_to_index[street_id];
      street = this.streets[street_idx];
      if (!street) {
        return;
      }
      if (!this.funds_available(Block.costs.excavation)) {
        new FundsNotAvailableAlert();
        throw 'Funds not available';
      }
      this.spend_funds(Block.costs.excavation);
      new_block = street.create_block(props);
      this.blocks.push(new_block);
      return this.block_ids_to_index[new_block.id] = this.blocks.length - 1;
    };

    Town.prototype._resident_id = function() {
      return this.next_resident_id += 1;
    };

    Town.prototype._resident_props = function(props) {
      if (props == null) {
        props = {};
      }
      return _.extend({
        id: this._resident_id(),
        name: 'Mr Resident'
      }, props);
    };

    Town.prototype.create_resident = function(props) {
      var new_resident;
      if (props == null) {
        props = {};
      }
      props = this._resident_props(props);
      new_resident = new Resident(null, props);
      return this.residents.push(new_resident);
    };

    Town.prototype.render_streets = function() {
      var s, _i, _len, _ref1, _results;
      _ref1 = this.streets;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        s = _ref1[_i];
        _results.push(s.render());
      }
      return _results;
    };

    Town.prototype.add_funds = function(how_much) {
      if (how_much == null) {
        how_much = 0;
      }
      return this.balance += how_much;
    };

    Town.prototype.spend_funds = function(how_much) {
      if (how_much == null) {
        how_much = 0;
      }
      this.spent += how_much;
      return this.balance -= how_much;
    };

    Town.prototype.funds_available = function(how_much) {
      if (how_much == null) {
        how_much = 0;
      }
      return (this.balance - how_much) >= 0;
    };

    Town.prototype.build_structure = function(type, street_id, block_id) {
      var new_structure;
      if (!_.has(Block.costs, type)) {
        throw 'Bad type';
      }
      if (!this.funds_available(Block.costs[type])) {
        new FundsNotAvailableAlert();
        throw 'Funds not available';
      }
      this.spend_funds(Block.costs[type]);
      street_id = this.street_ids_to_index[street_id];
      if (!_.has(this.streets, street_id)) {
        return;
      }
      new_structure = this.streets[street_id].build_structure(type, block_id);
      if (!new_structure) {
        throw 'Error creating structure';
      }
      this.structures.push(new_structure);
      this.structure_ids_to_index[new_structure.id] = this.structures.length - 1;
      return new_structure;
    };

    Town.prototype.setup_events = function() {
      var _this = this;
      return this.container.on('click', function(e) {
        var $el;
        e.preventDefault();
        $el = $(e.target);
        switch ($el.data('action')) {
          case 'build_structure':
            return _this.build_structure($el.data('value'), $el.closest('.street').data('id'), $el.closest('.block').data('id'));
          case 'add_block':
            return _this.create_block($el.closest('.street').data('id'));
        }
      });
    };

    return Town;

  })(RenderedObject);

  /* --------------------------------------------
       Begin Street.coffee
  --------------------------------------------
  */


  Street = (function(_super) {
    __extends(Street, _super);

    function Street() {
      Street.__super__.constructor.apply(this, arguments);
      this.state = new StateManager('setup');
      this.block_tmpl = _.template($('#block-template').html());
      this.name = '';
      this.num_blocks = 0;
      this.max_blocks = 6;
      this.next_block_id = 0;
      this.blocks = [];
      this.block_ids_to_index = {};
      this.structures = [];
      this.structure_ids_to_index = {};
    }

    Street.prototype.setup_blocks = function() {
      var i, _i, _ref1;
      for (i = _i = 1, _ref1 = this.opts.blocks; 1 <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = 1 <= _ref1 ? ++_i : --_i) {
        this.create_block();
      }
      return this.num_blocks = this.blocks.length;
    };

    Street.prototype.render = function() {
      var b, _i, _len, _ref1, _results;
      Street.__super__.render.apply(this, arguments);
      _ref1 = this.blocks;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        b = _ref1[_i];
        _results.push(b.render());
      }
      return _results;
    };

    Street.prototype.update = function() {
      var b, _i, _len, _ref1;
      switch (this.state.current()) {
        case 'setup':
          this.setup_blocks();
          this.state.change_state('running');
          break;
        case 'running':
          _ref1 = this.blocks;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            b = _ref1[_i];
            b.update();
          }
      }
      return this.state.update();
    };

    Street.prototype._block_id = function() {
      return this.next_block_id += 1;
    };

    Street.prototype._block_props = function(props) {
      if (props == null) {
        props = {};
      }
      return _.extend({
        id: this._block_id()
      }, props);
    };

    Street.prototype.create_block = function(props) {
      var $new_block, new_block;
      if (props == null) {
        props = {};
      }
      if (!(this.num_blocks < this.max_blocks)) {
        return;
      }
      props = this._block_props(props);
      $new_block = this.block_tmpl({
        id: props.id
      });
      this.container.find('.blocks').append($new_block);
      new_block = new Block(this.container.find(".block[data-id=" + props.id + "]"), props);
      this.blocks.push(new_block);
      this.block_ids_to_index[new_block.id] = this.blocks.length - 1;
      return this.num_blocks = this.blocks.length;
    };

    Street.prototype.build_structure = function(type, build_id) {
      var block_idx, new_structure;
      if (!_.has(this.block_ids_to_index, build_id)) {
        throw 'Bad block id';
      }
      block_idx = this.block_ids_to_index[build_id];
      new_structure = this.blocks[block_idx].build_structure(type);
      this.structures.push(new_structure);
      this.structure_ids_to_index[new_structure.id] = this.structures.length - 1;
      return new_structure;
    };

    Street.prototype.setup_events = function() {};

    return Street;

  })(RenderedObject);

  /* --------------------------------------------
       Begin Block.coffee
  --------------------------------------------
  */


  Block = (function(_super) {
    __extends(Block, _super);

    Block.costs = {
      excavation: 50,
      housing: 4,
      farm: 5,
      factory: 5
    };

    function Block() {
      Block.__super__.constructor.apply(this, arguments);
      this.type = '';
      this.structure = null;
      this.update();
    }

    Block.prototype.update = function() {
      if (this.structure) {
        this.structure.update();
      }
      return this.set_view_data('block', {
        type: this.type,
        structure: this.structure
      });
    };

    Block.prototype.render = function() {
      Block.__super__.render.apply(this, arguments);
      if (this.structure) {
        return this.structure.render();
      }
    };

    Block.prototype.build_structure = function(type) {
      switch (type) {
        case 'housing':
          this.build_housing();
          break;
        case 'farm':
          this.build_farm();
          break;
        case 'factory':
          this.build_factory();
      }
      this.container.find('.build_actions').remove();
      this.container.find('.structure').show();
      return this.structure;
    };

    Block.prototype.build_housing = function() {
      return this.structure = new Housing(this.container.find('.structure'));
    };

    Block.prototype.build_farm = function() {
      return this.structure = new Farm(this.container.find('.structure'));
    };

    Block.prototype.build_factory = function() {
      return this.structure = new Factory(this.container.find('.structure'));
    };

    Block.prototype.setup_events = function() {};

    return Block;

  })(RenderedObject);

  World.Block = Block;

  /* --------------------------------------------
       Begin Resident.coffee
  --------------------------------------------
  */


  Resident = (function(_super) {
    __extends(Resident, _super);

    function Resident() {
      _ref1 = Resident.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Resident.prototype.render = function() {};

    return Resident;

  })(RenderedObject);

  /* --------------------------------------------
       Begin Structure.coffee
  --------------------------------------------
  */


  Structure = (function(_super) {
    __extends(Structure, _super);

    function Structure() {
      Structure.__super__.constructor.apply(this, arguments);
      this.state = new StateManager('idle');
      this.type = '';
      this.cost = 1;
      this.construction_time = this.opts.construction_time;
      this.construction_time_remaining = 0;
      this.construction_started = null;
      this.construction_timer = null;
      this.built = false;
      this.construction_tmpl = _.template($('#structure-under-construction-template').html());
      if (this.opts.begin_construction) {
        this.begin_construction();
      }
    }

    Structure.prototype.default_opts = function() {
      return _.extend({
        begin_construction: true,
        construction_time: WorldClock.get_duration(1, 'minutes')
      }, Structure.__super__.default_opts.apply(this, arguments));
    };

    Structure.prototype.update = function() {
      switch (this.state.current()) {
        case 'under_construction':
          this.progress_construction();
          break;
        case 'operating':
          this.operating();
      }
      return this.state.update();
    };

    Structure.prototype.progress_construction = function() {
      if (!this.construction_timer) {
        return;
      }
      return this.construction_time_remaining = this.construction_timer.remaining();
    };

    Structure.prototype.begin_construction = function() {
      var _this = this;
      this.change_state('under_construction');
      this.construction_timer = World.game.clock.create_timer(this.construction_time, function() {
        return _this.finish_construction();
      });
      this.construction_time_remaining = this.construction_timer.remaining();
      this.construction_started = World.game.clock.now();
      return this.built = false;
    };

    Structure.prototype.finish_construction = function() {
      this.state.change_state('operating');
      return this.built = true;
    };

    Structure.prototype.get_view_data = function() {
      var vdata;
      vdata = {};
      switch (this.state.current()) {
        case 'under_construction':
          vdata = {
            construction_time: this.construction_time,
            construction_time_remaining: this.construction_timer.remaining(),
            construction_percent_complete: this.construction_timer.remaining_percent(),
            construction_time_nice: moment.duration(this.construction_time_remaining, 'milliseconds').humanize()
          };
          break;
        default:
          vdata = {
            built: this.built
          };
      }
      return vdata;
    };

    Structure.prototype.operating = function() {};

    Structure.prototype.render = function() {
      if (this.state.current() === "under_construction") {
        this.container.empty();
        return this.container.html(this.construction_tmpl(this.get_view_data()));
      } else {
        return Structure.__super__.render.call(this, true);
      }
    };

    return Structure;

  })(RenderedObject);

  /* --------------------------------------------
       Begin Farm.coffee
  --------------------------------------------
  */


  Farm = (function(_super) {
    __extends(Farm, _super);

    function Farm() {
      _ref2 = Farm.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Farm.prototype.begin_construction = function() {
      this.construction_time = WorldClock.get_duration(5, 'minutes');
      return Farm.__super__.begin_construction.apply(this, arguments);
    };

    Farm.prototype.template_id = function() {
      return '#farm-template';
    };

    return Farm;

  })(Structure);

  /* --------------------------------------------
       Begin Factory.coffee
  --------------------------------------------
  */


  Factory = (function(_super) {
    __extends(Factory, _super);

    function Factory() {
      _ref3 = Factory.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Factory.prototype.template_id = function() {
      return '#factory-template';
    };

    return Factory;

  })(Structure);

  /* --------------------------------------------
       Begin Housing.coffee
  --------------------------------------------
  */


  Housing = (function(_super) {
    __extends(Housing, _super);

    function Housing() {
      Housing.__super__.constructor.apply(this, arguments);
      this.max_occupants = 10;
      this.occupants = 0;
      this.rent_cost = 0;
    }

    Housing.prototype.has_vacancy = function() {
      return (this.occupants < this.max_occupants) != null;
    };

    Housing.prototype.move_resident_in = function(resident) {};

    Housing.prototype.move_Resident_out = function(resident) {};

    Housing.prototype.template_id = function() {
      return '#housing-template';
    };

    return Housing;

  })(Structure);

  /* --------------------------------------------
       Begin Player.coffee
  --------------------------------------------
  */


  Player = (function() {
    function Player() {}

    return Player;

  })();

  /* --------------------------------------------
       Begin main.coffee
  --------------------------------------------
  */


  /* --------------------------------------------
       Begin game.coffee
  --------------------------------------------
  */


  ModTownGame = (function(_super) {
    __extends(ModTownGame, _super);

    function ModTownGame() {
      ModTownGame.__super__.constructor.apply(this, arguments);
      this.clock = new WorldClock();
      this.clock.tick();
      this.state = new StateManager('init');
      this.setup_player();
      this.setup_hud();
      this.setup_town();
      this.setup_events();
      this.setup_timeout();
      this.update();
      this.render();
    }

    ModTownGame.prototype.setup_player = function() {
      return this.player = new Player();
    };

    ModTownGame.prototype.setup_town = function() {
      var town_opts;
      town_opts = {
        name: 'AhhsumTown',
        balance: 1000
      };
      return this.town = new Town(this.container.find('#town'), town_opts);
    };

    ModTownGame.prototype.setup_hud = function() {
      var _this = this;
      this.hud = new HUD(this.container.find('#hud'), {
        town: this.town
      });
      return this.hud.container.on('btn_pressed', function(e, action) {
        switch (action) {
          case 'add_street':
            return _this.town.create_street({
              blocks: 1
            });
        }
      });
    };

    ModTownGame.prototype.setup_timeout = function() {
      var _this = this;
      this.timeout = null;
      return this.timeout = setInterval(function() {
        return _this.update();
      }, 60000 / 60);
    };

    ModTownGame.prototype.pause = function(resume_in) {
      var _this = this;
      if (resume_in == null) {
        resume_in = null;
      }
      if (this.timeout) {
        clearInterval(this.timeout);
      }
      if (resume_in) {
        return setTimeout(function() {
          return _this.resume();
        }, resume_in);
      }
    };

    ModTownGame.prototype.resume = function() {
      return this.setup_timeout();
    };

    ModTownGame.prototype.update = function() {
      this.state.update();
      this.town.update();
      this.hud.update({
        town: this.town,
        player: this.player,
        clock: this.clock
      });
      return this.render();
    };

    ModTownGame.prototype.render = function() {
      ModTownGame.__super__.render.apply(this, arguments);
      this.hud.render(true);
      return this.town.render();
    };

    return ModTownGame;

  })(RenderedObject);

  $(function() {
    return World.game = new ModTownGame("#container");
  });

}).call(this);
