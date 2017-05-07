--[[----------------------------------------------------------------------------
AircraftWriteTitle.lua
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

local AircraftWriteTitle = {}

function AircraftWriteTitle()

	startLogger('AircraftWriteTitle')
	loadPrefs()

	-- initialize variables
	local catalog = LrApplication.activeCatalog()
	local selectedPhotos = catalog:getTargetPhotos()
	local messageEnd = 'Aircraft Create Title finished'
	local countSelected = 0
	local countProcessed = 0
	local countSkipped = 0
	local flagRun = true
	local progressScope, dialogAction, photo, photoLogFilename, textRegistration, textAirline, textAircraftManufacturer, textAircraftType

	LrFunctionContext.callWithContext("Aircraft Create Title", function(context)
		-- define progress bar
		progressScope = LrProgressScope({title = 'writing Aircraft Metadata to Title'})
		progressScope:setCancelable(true)
		-- cleanup if error is thrown
		context:addCleanupHandler(function()
			progressScope:done()
		end)

		-- check if user selected at least one photos
		if catalog:getTargetPhoto() == nil then
			dialogAction = LrDialogs.confirm('Write Aircraft Metadata to Title', 'No photo selected - run update on all photos in filmstrip?', 'Yes', 'No')
			if dialogAction == 'cancel' then
				-- cleanup if canceled by user
				flagRun = false
				messageEnd = 'Write Aircraft Metadata to Title canceled'
				LrLogger:info('no active photo selection - user canceled run on entire filmstrip')
			else
				LrLogger:info('no active photo selection - running on entire filmstrip')
			end
		end

		-- check if user hit cancel in dialog
		if flagRun then
			-- count selected photos
			for _ in pairs(selectedPhotos) do
				countSelected = countSelected + 1
			end
			LrLogger:info('performing update on '..countSelected..' selected photos')
			for _, photo in ipairs (selectedPhotos) do
				countProcessed = countProcessed + 1
				-- check if user hit cancel in progress bar
				if progressScope:isCanceled() then
					messageEnd = 'Aircraft Create Title canceled'
					LrLogger:info('canceled by user')
					break
				else
					-- set photo name for logging
					photoLogFilename = setPhotoLogFilename(photo)
					-- check if a registration is set
					if photo:getPropertyForPlugin(_PLUGIN, 'registration') == nil then
						-- photo has no registration
						LrLogger:info(photoLogFilename..' - skipped: no registration set')
						countSkipped = countSkipped + 1
					else
						-- create and write metadata to title
						writeTextField('title', catalog, photo, photoLogFilename)
					end
					progressScope:setPortionComplete(countProcessed, countSelected)
				end
			end
		end
		progressScope:done()
		LrLogger:info('processed '..countProcessed..' of '..countSelected..' selected photos ('..countSkipped..' skipped)')
		LrDialogs.showBezel(messageEnd)
		LrLogger:info('>>>> done')
	end)
end

LrTasks.startAsyncTask(AircraftWriteTitle)
