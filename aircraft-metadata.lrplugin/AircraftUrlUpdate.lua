--[[----------------------------------------------------------------------------
AircraftUrlUpdate.lua
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
require "Utilities"

function AircraftUrlUpdate()
	LrFunctionContext.callWithContext( "Aircraft Metadata Import", function(context)
		-- define progress bar
		progressScope = LrProgressScope({title = 'Aircraft URL Update'})
		progressScope:setCancelable(true)
		-- cleanup if error is thrown
		context:addCleanupHandler(function()
			progressScope:done()
		end)

		loadPrefs()
		startLogger('AircraftUrlUpdate')

		-- initialize variables
		messageEnd = 'Aircraft URL Update finished'
		countSelected = 0
		countProcessed = 0
		countSkipped = 0
		flagRun = true

		-- check if user selected at least one photos
		if catalog:getTargetPhoto() == nil then
			dialogAction = LrDialogs.confirm('Aircraft URL Update', 'No photo selected - run update on all photos in filmstrip?', 'Yes', 'No')
			if dialogAction == 'cancel' then
				-- cleanup if canceled by user
				flagRun = false
				progressScope:done()
				messageEnd = 'Aircraft URL Update canceled'
				log_info('no active photo selection - user canceled run on entire filmstrip')
			end
		end

		-- check if user hit cancel in dialog
		if flagRun then
			-- count selected photos
			for _ in pairs(selectedPhotos) do
				countSelected = countSelected + 1
			end
			log_info('performing update on '..countSelected..' selected photos')
			for _, photo in ipairs (selectedPhotos) do
				countProcessed = countProcessed + 1
				-- check if user hit cancel in progress bar
				if progressScope:isCanceled() then
					messageEnd = 'Aircraft URL Update canceled'
					log_info('canceled by user')
					break
				else
					-- set photo name for logging
					-- check if we are working on a copy
					if photo:getFormattedMetadata('copyName') == nil then
						photoFilename = photo:getFormattedMetadata('fileName')..'          '
					else
						photoFilename = photo:getFormattedMetadata('fileName')..' ('..photo:getFormattedMetadata('copyName')..')'
					end
					-- check if a registration is set
					if photo:getPropertyForPlugin(_PLUGIN, 'registration') == nil then
						-- photo has no url, maybee metadata update failed
						log_info(photoFilename..' - skipped: no registration set')
						countSkipped = countSkipped + 1
					else
						-- check if url is set
						if photo:getPropertyForPlugin(_PLUGIN, 'aircraft_url') == nil then
							-- photo has no registration
							log_info(photoFilename..' - skipped: no url set')
							countSkipped = countSkipped + 1
						else
							-- looks good, go on
							oldURL = photo:getPropertyForPlugin(_PLUGIN, 'aircraft_url')
							newURL = LrStringUtils.trimWhitespace(LrPrefs.prefLookupUrl)..LrStringUtils.trimWhitespace(photo:getPropertyForPlugin(_PLUGIN, 'registration'))
							-- check if we need a update
							if oldURL == newURL then
								-- no
								log_info(photoFilename..' - '..oldURL..' is fine, no update necessary')
							else
								-- yes
								catalog:withWriteAccessDo('set aircraft metadata',
								function()
									photo:setPropertyForPlugin(_PLUGIN, 'aircraft_url', newURL)
								end)
								log_info(photoFilename..' - url updated: '..oldURL..' --> '..newURL)
							end
						end
					end
					progressScope:setPortionComplete(countProcessed, countSelected)
				end
			end
		end
		progressScope:done()
		log_info('processed '..countProcessed..' of '..countSelected..' selected photos ('..countSkipped..' skipped)')
		LrDialogs.showBezel(messageEnd)
		log_info('>>>> done')
	end)
end


import 'LrTasks'.startAsyncTask(AircraftUrlUpdate)
