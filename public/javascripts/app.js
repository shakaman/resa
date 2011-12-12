$(document).ready(function() {
    $(function(){
    Backbone.Model.prototype.idAttribute = "_id";
    var Rooms = Backbone.Collection.extend({
        model: Room,
        url: 'rooms.json',
        parse: function(response) {
            _.each(response, function(room) {
                room.id = room._id;
            })
            return response;
        },
        colorForEvent: function(event) {
            return this.get(event.get('location_id')).get('color');
        }
    });

    var Room = Backbone.Model.extend({
        defaults: {
            name: null,
            color: null
        }
    });

    var Event = Backbone.Model.extend({
        defaults: {
            dtstart: null,
            start: null,
            dtend: null,
            end: null,
            title: null,
            location_id: null
        },
        url: function() {
            return '/events' + (this.isNew() ? '' : ('/' + this.id));
        },
        initialize: function() {
            _.bindAll(this, 'setColor', 'setDtstart', 'setDtend');
            if(this.get('location_id')) this.setColor();
            if(this.get('start')) this.setDtstart();
            if(this.get('end')) this.setDtend();
            this.bind('change:location_id', this.setColor);
            this.bind('change:start', this.setDtstart);
            this.bind('change:end', this.setDtend);
        },

        // keep sync between location and it's associate color'
        setColor: function() {
            this.set({color: rooms.colorForEvent(this)});
        },
        // keep sync between full calendar date and server side
        setDtstart: function() {
            this.set({dtstart: this.get('start')});
        },
        // keep sync between full calendar date and server side
        setDtend: function() {
            this.set({dtend: this.get('end')});
        },
        toCallendar: function() {
            var format = this.toJSON();
            format.id = this.id;
            var organizer = this.get('organizer')
            format.title = this.get('title') + (organizer ? (' | ' + organizer.email) : '');

            return format;
        }

    });

    var Events = Backbone.Collection.extend({
        model: Event,
        url: '/events',
        parse: function(response) {
            _.each(response, function(event) {
                event.start = event.dtstart;
                event.end = event.dtend;
            });
            return response;
        },
        toCallendar: function() {
            var t = this.map(function(event) {return event.toCallendar()});
            return t;
        }
    });

    var LegendView = Backbone.View.extend({
        el: $('#legend'),
        initialize: function() {
            _.bindAll(this);
            this.collection.bind('reset', this.render);
        },
        render: function() {
            var html = "";
            rooms.each(function(room) {
                //html += '<div style="float: left; width: 150px; margin: 15px; color: #fff; background-color: ' + room.get('color') +'">' + room.get('name') + '</div>';
                html += '<div class="ui-button ui-button-text-only" style="background-color: ' + room.get('color') +'"><div class="ui-button-text">' + room.get('name') + '</div></div>';
            });
            this.el.html(html);
            return this;
        }
    });

    var EventsView = Backbone.View.extend({
        initialize: function(){
            _.bindAll(this);

            this.collection.bind('reset', this.addAll);
            this.collection.bind('add', this.addOne);
            this.collection.bind('change', this.change);
            this.collection.bind('destroy', this.destroy);

            this.eventView = new EventView();
            this.legendView = new LegendView({collection: rooms});
        },
        render: function() {
            this.el.fullCalendar({
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                buttonText: {
                    prev:     '&nbsp;&#9668;&nbsp;',  // left triangle
                    next:     '&nbsp;&#9658;&nbsp;',  // right triangle
                    prevYear: '&nbsp;&lt;&lt;&nbsp;', // <<
                    nextYear: '&nbsp;&gt;&gt;&nbsp;', // >>
                    today:    'aujourd\'hui',
                    month:    'mois',
                    week:     'semaine',
                    day:      'jour'
                },
                titleFormat: {
                    month: 'MMMM yyyy',
                    week: "d MMMM[ yyyy]{ - d [ MMMM] yyyy}",
                    agendaDay: 'dddd d MMM yyyy'
                },
                columnFormat: {
                    month: 'ddd',
                    week: 'ddd d/M',
                    day: 'dddd d/M'
                },
                monthNames: ['Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet',
                 'Aout', 'Septembre', 'Octobre', 'Novembre', 'Decembre'],
                monthNamesShort: ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Jui', 'Jui',
                 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'],
                dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
                dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
                firstDay: 1,
                timeFormat: 'H:mm{ - H:mm}',
                axisFormat: 'H:mm',
                defaultView: 'agendaWeek',
                minTime: 8,
                maxTime: 21,
                allDayDefault: false,
                allDaySlot: false,
                selectable: true,
                selectHelper: true,
                editable: true,
                ignoreTimezone: false,
                select: this.select,
                eventClick: this.eventClick,
                eventDrop: this.eventDropOrResize,
                eventResize: this.eventDropOrResize
            });
        },
        addAll: function() {
            this.el.fullCalendar('addEventSource', this.collection.toCallendar());
        },
        addOne: function(event) {
            this.el.fullCalendar('renderEvent', event.toCallendar());
        },
        select: function(startDate, endDate) {
            this.eventView.collection = this.collection;
            this.eventView.model = new Event({
                start: $.fullCalendar.formatDate(startDate, 'u'),
                end: $.fullCalendar.formatDate(endDate, 'u')
            });
            this.eventView.render();
        },
        eventClick: function(fcEvent) {
            this.eventView.model = this.collection.get(fcEvent.id);
            this.eventView.render();
        },
        change: function(event) {
            // Look up the underlying event in the calendar and update its details from the model
            var fcEvent = this.el.fullCalendar('clientEvents', event.id)[0];
            var organizer = event.get('organizer')
            fcEvent.title = event.get('title') + (organizer ? (' | ' + organizer.email) : '');
            fcEvent.color = event.get('color');
            fcEvent.start = event.get('start');
            fcEvent.end = event.get('end');
            this.el.fullCalendar('updateEvent', fcEvent);
        },
        eventDropOrResize: function(fcEvent) {
            // Lookup the model that has the ID of the event and update its attributes
            var event = this.collection.get(fcEvent.id)
              , values = {start: fcEvent.start, end: fcEvent.end}
              , el = this.el;
            $.when(
                event.clone().save(values))
                .done(function() {event.set(values, {silent: true})})
                .fail(function() {
                    $.gritter.add({title: Wording.error, text: Wording.update.unauthorized});
                })
                .fail(function() {
                    var fcEvent = el.fullCalendar('clientEvents', event.id)[0];
                    fcEvent.start = event.get('start');
                    fcEvent.end = event.get('end');
                    el.fullCalendar('updateEvent', fcEvent);
                });
        },
        destroy: function(event) {
            this.el.fullCalendar('removeEvents', event.id);
        }
    });

    var EventView = Backbone.View.extend({
        el: $('#eventDialog'),
        initialize: function() {
            _.bindAll(this);
        },
        render: function() {
            var buttons = {'Ok': this.save};
            if (!this.model.isNew()) {
                _.extend(buttons, {'Delete': this.destroy});
            }
            _.extend(buttons, {'Cancel': this.close});

            this.el.dialog({
                modal: true,
                title: (this.model.isNew() ? 'New' : 'Edit') + ' Event',
                buttons: buttons,
                open: this.open
            });

            return this;
        },
        open: function() {
            this.$('#title').val(this.model.get('title'));
            var begin = $.fullCalendar.parseDate(this.model.get('start'));
            this.$('#begin').val($.fullCalendar.formatDate(begin, 'HH:mm'));
            this.$('#begin').timepicker();
            var end = $.fullCalendar.parseDate(this.model.get('end'));
            this.$('#end').val($.fullCalendar.formatDate(end, 'HH:mm'));
            this.$('#end').timepicker();
            var room = new RoomsSelectView({el: this.$('#rooms')});
            room.render({selected: this.model.get('location_id')});
        },
        save: function() {
            var start = $.fullCalendar.parseDate(this.model.get('start'))
              , newStart = $.fullCalendar.formatDate(start, "yyyy-MM-dd'T"+this.$('#begin').val()+"':ssTZO")
              , end = $.fullCalendar.parseDate(this.model.get('start'))
              , newEnd = $.fullCalendar.formatDate(end, "yyyy-MM-dd'T"+this.$('#end').val()+"':ssTZO");
            var values = {
                'title': this.$('#title').val(),
                'start': newStart,
                'end': newEnd,
                'location_id': this.$('select[name="rooms"] :selected').val()};

            if (this.model.isNew()) {
                this.model.set(values);
                $.when(
                    this.collection.create(this.model))
                    .then(this.close);
            } else {
                var model = this.model;
                $.when(
                    model.clone().save(values))
                    .done(function() {model.set(values)})
                    .then(this.close)
                    .fail(function(){$.gritter.add({title: Wording.error, text: Wording.update.unauthorized})});
            }
        },
        close: function() {
            this.el.dialog('close');
        },
        destroy: function() {
            $.when(
                this.model.destroy())
                .then(this.close)
                .fail(function(){$.gritter.add({title: Wording.error, text: Wording.delete.unauthorized})});
        }
    });
    
    var RoomsSelectView = Backbone.View.extend({
        render: function(options) {
            var select = $('<select name="rooms"/>');
            rooms.each(function(room) {
                var selected = options.selected == room.id;
                select.append('<option value="'+room.id +'"'+ (selected  ? ' selected' : '') +'>'+room.get('name')+'</option>');
            });
            this.el.html(select);
        }
    });

    var events = new Events();
    var rooms = new Rooms();
    new EventsView({el: $("#main"), collection: events}).render();
    rooms.fetch().done(_.bind(events.fetch, events)); // need rooms config before displaying.
});

});

var Wording = {
    'error': 'Erreur',
    'update': {
        unauthorized: 'Vous n\'êtes pas autorisé à modifier cet événement.'
    },
    'delete': {
        unauthorized: 'Vous n\'êtes pas autorisé à supprimer cet événement.'
    }
};
