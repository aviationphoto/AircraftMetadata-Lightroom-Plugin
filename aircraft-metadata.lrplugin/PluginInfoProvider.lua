--[[----------------------------------------------------------------------------
PluginInfo.lua
This file is part of LR Aircraft Metadata.
Copyright(c) 2017, aviationphoto

LR Aircraft Metadata is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LR Aircraft Metadata is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LR Aircraft Metadata.  If not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]
function sectionsForTopOfDialog(viewFactory, propertyTable)
	local LrView = import 'LrView'
	local LrBinding = import 'LrBinding'
	local bind = LrView.bind
	local LrPrefs = import 'LrPrefs'.prefsForPlugin()

	local LrFileUtils = import 'LrFileUtils'
	local LrPathUtils = import 'LrPathUtils'
	local logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadatLookup.log')

	return {
		{
			title = 'Settings',
			viewFactory:row {
				viewFactory:checkbox {
					title = 'Enable logging to ',
					value = bind {key = 'prefFlagLogging', object = LrPrefs},
				},
				viewFactory:static_text {
					title = logPath,
				},
			},
			viewFactory:row {
				viewFactory:static_text {
					title = 'URL for lookup',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefLookupUrl', object = LrPrefs},
					width_in_chars = 40,
					wraps = false,
				},
			},
		},
	}
end

return{
	sectionsForTopOfDialog = sectionsForTopOfDialog,
}
