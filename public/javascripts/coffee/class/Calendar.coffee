class Calendar
    @days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    @months: ['First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth', 'Nineth', 'Tenth', 'Eleventh', 'Twelvth', 'Thirteenth', 'Fourteenth', 'Fifteenth', 'Sixteenth']

    @get_month: (index) ->
        return false if index >= Calendar.months.length
        Calendar.months[index]

    @get_day: (index) ->
        return false if index >= Calendar.days.length
        Calendar.days[index]

World.Calendar = Calendar
