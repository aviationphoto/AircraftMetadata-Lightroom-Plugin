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
	local prefs = import 'LrPrefs'.prefsForPlugin()

	local LrFileUtils = import 'LrFileUtils'
	local LrPathUtils = import 'LrPathUtils'
	local logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadatLookup.log')

	-- set text for section synopsis
	if prefs.prefFlagLogging == true then
		synopsisLog = 'logging enabled'
	else
		synopsisLog = 'logging disabled'
	end

	if prefs.prefFlagOverwrite == true then
		synopsisOverwrite = 'overwrite existing metadata'
	else
		synopsisOverwrite = 'logging disabled'
	end



	return {
		-- section log settings
		{
			title = 'Log Settings',
			synopsis = synopsisLog,
			-- logging
			viewFactory:row {
				viewFactory:checkbox {
					title = 'Enable logging to ',
					value = bind {key = 'prefFlagLogging', object = prefs},
				},
				viewFactory:static_text {
					title = logPath,
				},
			},
		},
		-- section overwrite settings
		{
			title = 'Metadata handling',
			synopsis = synopsisOverwrite,
			-- overwrite
			viewFactory:row {
				viewFactory:checkbox {
					title = 'Overwrite existing values ',
					value = bind {key = 'prefFlagOverwrite', object = prefs},
				},
			},
			-- write to title
			viewFactory:row {
				viewFactory:checkbox {
					title = 'After lookup, write metadata to photo title ',
					value = bind {key = 'prefFlagWriteTitle', object = prefs},
				},
			},

		},
		-- section tagging settings
		{
			title = 'Tagging',
			-- keyword reg not found
			viewFactory:row {
				viewFactory:static_text {
					title = 'Keyword if registration not found',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefKeywordRegNotFound', object = prefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
			-- keyword wrong reg
			viewFactory:row {
				viewFactory:static_text {
					title = 'Keyword if lookup returns wrong registration',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefKeywordWrongReg', object = prefs},
					width_in_chars = 20,
					wraps = false,
				},
			},
		},
		-- section metadata provider
		{
			title = 'Metadata provider',
			synopsis = prefs.prefMetadataProvider,
			-- jetphotos
			viewFactory:radio_button {
				title = "JetPhotos",
				value = bind {key = 'prefMetadataProvider', object = prefs},
				checked_value = 'jetphotos',
			},
		},
		-- section lookup settings
		{
			title = 'Aircraft lookup',
			synopsis = prefs.prefLookupUrl,
			-- lookup url
			viewFactory:row {
				viewFactory:static_text {
					title = 'URL for Aircraft lookup',
				},
				viewFactory:edit_field {
					value = bind {key = 'prefLookupUrl', object = prefs},
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
