require 'spec_helper'

describe TicketTimer do

  it { should belong_to :admin_user }
  it { should belong_to :ticket }
  it { should have_one(:project).through(:ticket) }

  describe '#created_by' do
    subject(:timer) { create(:ticket_timer) }

    it 'should find timers belonging to this user' do
      TicketTimer.created_by(timer.admin_user).should include(timer)
    end
  end

  describe '#elapsed_time' do
    subject(:timer) { create(:ticket_timer) }
    before { timer } # ensure time is created before we tamper with time

    it 'should calculate to 30 minutes' do
      Timecop.travel(30.minutes.from_now)
      timer.readable_elapsed.should == "00:30"
    end
  end

end
