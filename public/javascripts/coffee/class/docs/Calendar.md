# class Calendar

This class is a more literative interpretation of the WorldClock. The clock uses the static methods here for textual representations of "now". This class will eventually handle seasons and likely also weather.

## Static Properties

- days: The names of the days of the week in order. Weeks start with Sunday and follow a normal 7 day week order.
- months: The names of the months in order. There are currently sixteen months with temporary names.
- seasons: List of season names in order. Follows normal four seasons, starting with Spring.

## Static Methods

#### get_month (index)

Get the name of the month at this index. This method should be used instead of direct access because it does a safety check.

#### get_day (index)

Get the name of the day at this index. This method should be used instead of direct access because it does a safety check.

#### get_season (month)

Get the name of the season that the month (index) falls into. Each season is an even 4 months so this is a simple calculation.
