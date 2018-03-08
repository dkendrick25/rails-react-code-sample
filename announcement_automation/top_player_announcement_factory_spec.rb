# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementAutomation::TopPlayerAnnouncementFactory do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    before(:each) do
      @settings = create(:settings, weekly_limit: 3)
      @company = @settings.company
      @company.switch!
      @group = create(:group)
    end

    it 'creates a top player announcement for a group' do
      # Create a quiz with points a week ago so the query
      # can find something in the appropriate time frame.
      travel_to 1.week.ago do
        user = create(:user)
        user.add_to_group(@group)
        quiz = create(:complete_quiz, user: user)
      end

      AnnouncementAutomation::TopPlayerAnnouncementFactory.new(@company, [@group]).call

      expect(@group.announcements.first.notes).to eq('Top Player')
    end

    it 'does not create an announcement if points have not been earned' do
      # Create a quiz with points a week ago so the query
      # can find something in the appropriate time frame.
      travel_to 1.week.ago do
        user = create(:user)
        user.add_to_group(@group)
      end

      AnnouncementAutomation::TopPlayerAnnouncementFactory.new(@company, [@group]).call

      expect(@group.announcements.count).to eq(0)
    end
  end
end
