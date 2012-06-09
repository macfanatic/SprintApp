class ProjectFile < ActiveRecord::Base
  
  belongs_to :project
  
  mount_uploader :file, ProjectFileUploader
  
  acts_as_url :file, limit: 100
  
  def to_param
    url
  end
  
end