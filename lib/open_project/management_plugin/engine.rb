#-- copyright
# OpenProject management plugin.
# Copyright (C) 2020 Floris Janssens (florisjanssens@outlook.com)
#
# OpenProject is an open source project management software.
# Copyright (C) 2012-2020 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
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
# See doc/COPYRIGHT.md for more details.
#++

# Prevent load-order problems in case openproject-plugins is listed after a plugin in the Gemfile
# or not at all
require 'open_project/plugins'

module OpenProject::ManagementPlugin
  class Engine < ::Rails::Engine
    engine_name :openproject_management_plugin

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-management_plugin',
             author_url: 'https://openproject.org',
             global_assets: { css: 'management_plugin/management_plugin' },
             requires_openproject: '>= 10.5.2',
             bundled: true do

      menu :account_menu, :user_import,
           { controller: '/users', action: 'csv_import' },
           caption: "Bulk importer",
           before: :logout,
           if: Proc.new {
             User.current.logged? && User.current.allowed_to?(:import_users, nil, global: true)
           }
    end

    patches %i[UsersController]

    # Activate hooks to insert element into views of the core
    initializer 'management_plugin.register_hooks' do
      require 'open_project/management_plugin/hooks'
    end
  end
end
