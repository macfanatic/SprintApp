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

end
