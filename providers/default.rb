#
# Cookbook Name:: resolvconf
# Provider:: default
#
# Copyright 2012, Chris Aumann
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

action :create do
  options = {}
  options['head'] = Array(new_resource.head)
  options['base'] = Array(new_resource.nameserver).map { |ns| "nameserver #{ns}"}
  options['base'] += Array("search #{Array(new_resource.search).join(' ')}") unless new_resource.search.empty?
  options['base'] += Array(new_resource.options).map { |opt| "options #{opt}"}
  options['base'] += Array(new_resource.base)
  options['tail'] = Array(new_resource.tail)

  options.each do |name, config|
    r = file "/etc/resolvconf/resolv.conf.d/#{name}" do
      mode    00644
      content "#{options[name].join("\n")}\n"
    end

    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

  execute "#{new_resource.name}: delete dns-* configuration from /etc/network/interfaces" do
    command "sed -i '/\\s*dns-/d' /etc/network/interfaces"
    only_if { new_resource.clear_dns_from_interfaces }
  end

  execute 'resolvconf -u'
end