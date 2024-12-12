class View < ApplicationRecord
  belongs_to :story
  belongs_to :viewer, class_name: 'User'
end
