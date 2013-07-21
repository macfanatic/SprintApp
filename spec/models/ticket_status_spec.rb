require 'spec_helper'

describe TicketStatus do

  it { should have_many(:tickets).with_foreign_key(:status_id) }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  its(:active) { should be_true }  
end
