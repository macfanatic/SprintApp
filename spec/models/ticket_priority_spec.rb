require 'spec_helper'

describe TicketPriority do

  it { should have_many :tickets }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should validate_presence_of :weight }
  it { should ensure_inclusion_of(:weight).in_array(TicketPriority::WEIGHTS) }

end
