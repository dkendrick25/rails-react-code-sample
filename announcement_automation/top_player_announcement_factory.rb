# frozen_string_literal: true

#
module AnnouncementAutomation
  # This class builds an announcement for each group that showcases the top player
  # on the leaderboard from the previous week.
  #
  # Implementation can be found in app/lib/tasks/announcement_automation/create_top_player_announcements
  #
  class TopPlayerAnnouncementFactory
    def initialize(company, groups)
      @company = company
      @groups = groups
    end

    attr_reader :company, :groups

    def call
      groups.each do |g|
        top_player = get_top_player(g)

        # Don't bother making an announcement if the best person
        # is still 0.
        if top_player.points > 0
          top_player_announcement(top_player, g)
          set_as_top_player(g, top_player)
        end
      end
    end

    private

    # Runs the leaderboard query to find last week's top player in a group
    def get_top_player(group)
      service = Leaderboard::Base.new(
        query: Leaderboard::Queries::Users.new(company, 'last week', group),
        decorator: Leaderboard::Users
      )

      service.call.first
    end

    # Creates a new announcement record in the database
    def top_player_announcement(top_player, group)
      announcement = Announcement.create!(
        notes: 'Top Player',
        title: "Last Week's Leader",
        content: announcement_message(top_player, group),
        start_time: Time.current,
        end_time: Time.current.end_of_day + 2.weeks
      )
      announcement.add_to_group(group)
    end

    # This method sets the html content for the top player announcement
    def announcement_message(top_player, group)
      %(
        <div class='blastbot-announcement'>
          <div class="blastbot-announcement__image blastbot-announcement__image--top-player">
            <img src="#{top_player.avatar}" class="avatar avatar--large" />
          </div>
          <div class="blastbot-announcement__badge blastbot-announcement__badge--top-player">
            <img src="https://d2a6fgjx3l436r.cloudfront.net/static/images/Badge_TopPlayer_small.svg" />
          </div>
          <div class='blastbot-announcement__message'>
            <h3 class='blastbot-announcement__message--name'>#{top_player.name}</h3>
            <h4>#{top_player.points} Points</h4>
            <p>Look who finished at the top of the Leaderboard last week for #{group.name}!</p>
            <p><strong>Could you be this week's leader?</strong></p>
          </div>
        </div>
      )
    end

    # Sets the top player for each leaderboard group
    def set_as_top_player(group, top_player)
      group.set_top_player!(top_player.id)
    end
  end
end
