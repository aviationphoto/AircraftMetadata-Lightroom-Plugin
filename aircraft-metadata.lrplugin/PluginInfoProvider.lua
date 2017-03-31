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
			-- logging
			viewFactory:row {
				viewFactory:checkbox {
					title = 'Enable logging to ',
					value = bind {key = 'prefFlagLogging', object = LrPrefs},
				},
				viewFactory:static_text {
					title = logPath,
				},
			},
			-- overwrite
			viewFactory:row {
				viewFactory:checkbox {
					title = 'Overwrite existing metadata ',
					value = bind {key = 'prefFlagOverwrite', object = LrPrefs},
				},
			},
			viewFactory:row {
				viewFactory:separator {
					fill_horizontal = 1},
			},
			-- tag reg not found
			viewFactory:row {
				viewFactory:static_text {
					title = 'Keyword if registration not found',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefKeywordRegNotFound', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
			viewFactory:row {
				viewFactory:separator {
					fill_horizontal = 1},
			},
			-- lookup url
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
			-- tokens
			viewFactory:row {
				viewFactory:static_text {
					title = 'Registration',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefRegistrationToken1', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
				viewFactory:edit_field {
					value = bind {key = 'prefRegistrationToken2', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
			viewFactory:row {
				viewFactory:static_text {
					title = 'Airline',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefAirlineToken1', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
				viewFactory:edit_field {
					value = bind {key = 'prefAirlineToken2', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
			viewFactory:row {
				viewFactory:static_text {
					title = 'Aircraft',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefAircraftToken1', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
				viewFactory:edit_field {
					value = bind {key = 'prefAircraftToken2', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
			viewFactory:row {
				viewFactory:static_text {
					title = 'Manufacturer',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefManufacturerToken1', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
				viewFactory:edit_field {
					value = bind {key = 'prefManufacturerToken2', object = LrPrefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
		},
	}
end

return{
	sectionsForTopOfDialog = sectionsForTopOfDialog,
}
