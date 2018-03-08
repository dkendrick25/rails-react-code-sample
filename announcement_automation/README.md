# Announcement Automation - Top Player Announcement

To help announcement creation for our clients we decided to add a feature that would
create several automated announcements for users. The top player announcement is
one of three automated announcements. This announcement ran every week and would
display the player that was first the leaderboard for the previous week.

### Architecture

This service object was ran by a cron job (not included) every Monday. This service
finds the player that achieved the most points in each group from the previous
week. An announcement is created and added to the database that will be seen to
everyone within that group. This feature also includes giving the top player a badge
that will be displayed on the leaderboard for a week. This service also includes the
method `set_as_top_player` for that badge to get set to be displayed elsewhere in the app.
Also in this sample is an example of some of the testing within our application.