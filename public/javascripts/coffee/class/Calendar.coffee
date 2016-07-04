class Calendar
  @days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
  @months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

  @get_month: (index) ->
    return false if index >= Calendar.months.length
    Calendar.months[index]

  @get_day: (index) ->
    return false if index >= Calendar.days.length
    Calendar.days[index]

World.Calendar = Calendar
