#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class WikiMenuItem < ActiveRecord::Base
  belongs_to :wiki
  belongs_to :parent, :class_name => 'WikiMenuItem'
  has_many :children, :class_name => 'WikiMenuItem', :dependent => :destroy, :foreign_key => :parent_id, :order => 'id ASC'

  serialize :options, Hash

  scope :main_items, lambda { |wiki_id|
    {:conditions => {:wiki_id => wiki_id, :parent_id => nil},
    :include => :children,
     :order => 'id ASC'}
  }

  attr_accessible :name, :title, :wiki_id

  validates_presence_of :title
  validates_format_of :title, :with => /\A[^,\.\/\?\;\|\:]*\z/
  validates_uniqueness_of :title, :scope => :wiki_id

  validates_presence_of :name

  def item_class
    title.dasherize
  end

  def setting
    if new_record?
      :no_item
    elsif is_main_item?
      :main_item
    else
      :sub_item
    end
  end

  def new_wiki_page
    !!options[:new_wiki_page]
  end

  def new_wiki_page=(value)
    options[:new_wiki_page] = value
  end

  def index_page
    !!options[:index_page]
  end

  def index_page=(value)
    options[:index_page] = value
  end

  def is_main_item?
    parent_id.nil?
  end

  def is_sub_item?
    !parent_id.nil?
  end

  def is_only_main_item?
    self.class.main_items(wiki.id) == [self]
  end
end
