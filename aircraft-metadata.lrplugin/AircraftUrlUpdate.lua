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

local AircraftUrlUpdate = {}

function AircraftUrlUpdate()
	LrFunctionContext.callWithContext( "Aircraft Metadata Import", function(context)
		-- define progress bar
		local progressScope = LrProgressScope({title = 'Aircraft URL Update'})
		progressScope:setCancelable(true)
		-- cleanup if error is thrown
		context:addCleanupHandler(function()
			progressScope:done()
		end)

		loadPrefs()

		local messageEnd = 'Aircraft URL Update finished'
		local countSelected = 0
		local countProcessed = 0
		local countSkipped = 0
		local flagRun = true

		-- check if logging enabled
		if prefs.prefFlagLogging then
			logger:enable('logfile')
			clearLogfile()
		else
			logger:disable()
		end

		logger:info('>>>> running AircraftUrlUpdate')

		-- lookup URL
		lookupURL = trim(prefs.prefLookupUrl)

		-- get a reference to the photos within the current catalog
		local catalog = LrApplication.activeCatalog()
		local selectedPhotos = catalog:getTargetPhotos()

		-- check if user selected at least one photos
		if catalog:getTargetPhoto() == nil then
			local dialogAction = LrDialogs.confirm('Aircraft URL Update', 'No photo selected - run update on all photos in filmstrip?', 'Yes', 'No')
			if dialogAction == 'cancel' then
				-- cleanup if canceled by user
				flagRun = false
				progressScope:done()
				messageEnd = 'Aircraft URL Update canceled'
				logger:info('no active photo selection - user canceled run on entire filmstrip')
			end
		end

		-- check if user hit cancel in dialog
		if flagRun then
			-- count selected photos
			for _ in pairs(selectedPhotos) do
				countSelected = countSelected + 1
			end
			logger:info('performing update on '..countSelected..' selected photos')
			for _, photo in ipairs (selectedPhotos) do
				countProcessed = countProcessed + 1
				-- read photo name for logging
				-- check if we are working on a copy
				if photo:getFormattedMetadata('copyName') == nil then
					photoFilename = photo:getFormattedMetadata('fileName')
				else
					photoFilename = photo:getFormattedMetadata('fileName')..' ('..photo:getFormattedMetadata('copyName')..')'
				end
				-- check if a registration is set
				if photo:getPropertyForPlugin(_PLUGIN, 'registration') == nil then
					-- photo has no url
					logger:info(photoFilename..' - skipped: no registration set')
					countSkipped = countSkipped + 1
				else
					-- check if url is set
					if photo:getPropertyForPlugin(_PLUGIN, 'aircraft_url') == nil then
						-- photo has no registration
						logger:info(photoFilename..' - skipped: no url set')
						countSkipped = countSkipped + 1
					else
						-- looks good, do the update
						oldURL = photo:getPropertyForPlugin(_PLUGIN, 'aircraft_url')
						newURL = lookupURL..trim(photo:getPropertyForPlugin(_PLUGIN, 'registration'))
						catalog:withWriteAccessDo('set aircraft metadata',
						function()
							photo:setPropertyForPlugin(_PLUGIN, 'aircraft_url', newURL)
						end)
						logger:info(photoFilename..' - url updated: '..oldURL..' --> '..newURL)
					end
				end
				progressScope:setPortionComplete(countProcessed, countSelected)
			end
		end
		progressScope:done()
		logger:info('processed '..countProcessed..' photos ('..countSkipped..' skipped)')
		LrDialogs.showBezel(messageEnd)
		logger:info('>>>> lookup done')
	end)
end


import 'LrTasks'.startAsyncTask(AircraftUrlUpdate)
