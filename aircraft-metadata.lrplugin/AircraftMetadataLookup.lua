--[[----------------------------------------------------------------------------
AircraftmetadataLookup.lua
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
require 'Utilities'
require 'AircraftMetadataProviderJP'

local AircraftMetadataImport = {}

function AircraftMetadataImport()

	startLogger('AircraftMetadataLookup')
	loadPrefs()

	-- initialize variables
	local catalog = LrApplication.activeCatalog()
	local selectedPhotos = catalog:getTargetPhotos()
	local messageStart = 'looking up Aircraft Metadata'
	local messageEnd = 'Aircraft Metadata Lookup finished'
	local metadataCache = {}
	local regNotFoundCache = {}
	local countSelected = 0
	local countProcessed = 0
	local countCacheHit = 0
	local countLookup = 0
	local countNoReg = 0
	local countRegNotFound = 0
	local flagRegFound = true
	local flagRun = true
	local flagLookupResult = ''
	local progressScope, keywordRegNotFound, keywordWrongReg, dialogAction, photo, photoLogFilename, searchRegistration, lookupURL, result
	local foundRegistration, foundAirline, foundAircraft, foundAircraftManufacturer, foundAircraftType

	LrFunctionContext.callWithContext( "Aircraft Metadata Import", function(context)
		-- define progress bar
		progressScope = LrProgressScope({title = 'looking up Aircraft Metadata'})
		progressScope:setCancelable(true)
		-- cleanup if error is thrown
		context:addCleanupHandler(function()
			progressScope:done()
		end)

		-- create / get keyword
		catalog:withWriteAccessDo('set keyword',
		function()
			keywordRegNotFound = catalog:createKeyword(LrPrefs.prefKeywordRegNotFound, {}, false, nil, true)
			keywordWrongReg = catalog:createKeyword(LrPrefs.prefKeywordWrongReg, {}, false, nil, true)
		end)

		-- check if user selected at least one photos
		if catalog:getTargetPhoto() == nil then
			dialogAction = LrDialogs.confirm('Aircraft Metadata Lookup', 'No photo selected - run lookup on all photos in filmstrip?', 'Yes', 'No')
			if dialogAction == 'cancel' then
				-- cleanup if canceled by user
				flagRun = false
				progressScope:done()
				messageEnd = 'Aircraft Metadata Lookup canceled'
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
			LrDialogs.showBezel(messageStart)
			LrLogger:info('performing lookup for '..countSelected..' selected photos')
			-- loop through each of the photos
			for _, photo in ipairs (selectedPhotos) do
				countProcessed = countProcessed + 1
				flagRegFound = true
				-- check if user hit cancel in progress bar
				if progressScope:isCanceled() then
					messageEnd = 'Aircraft Metadata Lookup canceled'
					LrLogger:info('canceled by user')
					break
				else
					-- set photo name for logging
					photoLogFilename = setPhotoLogFilename(photo)
					-- read aircraft registration from photo
					searchRegistration = photo:getPropertyForPlugin(_PLUGIN, 'registration')
					-- do we have a registration?
					if not (searchRegistration == '' or searchRegistration == nil) then
						-- yes, photo has registration
						searchRegistration = string.upper(LrStringUtils.trimWhitespace(searchRegistration))
						-- check if a previous lookup returnded a error for this registration
						if not regNotFoundCache[searchRegistration] then
							-- no, check if registration is already in cache
							if not metadataCache[searchRegistration] then
								-- no, we need to do a lookup
								countLookup = countLookup + 1
								-- invoke metadata provider
								if LrPrefs.prefMetadataProvider == 'jetphotos' then
									-- lookup metadata on jetphotos
									flagLookupResult, foundRegistration, foundAirline, foundAircraft, foundAircraftManufacturer, foundAircraftType, lookupURL = lookupMetadataJP(photoLogFilename, searchRegistration)
								else
									progressScope:done()
									LrLogger:error('no known metadata provider is set')
									LrErrors.throwUserError('No matching metadata provider is set!')
								end
								LrLogger:debug(photoLogFilename..' - lookup result: '..flagLookupResult)
								-- check result of lookup
								if flagLookupResult == 'success' then
									-- lookup successful
									LrLogger:info(photoLogFilename..' - metadata found: Reg: '..foundRegistration..', Airline: '..foundAirline..', Aircraft: '..foundAircraft..', Manufacturer: '..foundAircraftManufacturer..', Type: '..foundAircraftType)
									-- cache found metadata
									metadataCache[searchRegistration] = {foundRegistration = foundRegistration, foundAirline = foundAirline, foundAircraft = foundAircraft, foundAircraftManufacturer = foundAircraftManufacturer, foundAircraftType = foundAircraftType, lookupURL = lookupURL}
								elseif flagLookupResult == 'reg_not_found' then
									-- lookup returned registration not found
									LrLogger:warn(photoLogFilename..' - REG NOT FOUND: no metadata found for registration '..searchRegistration)
									countRegNotFound = countRegNotFound + 1
									flagRegFound = false
									-- mark photo with keyword reg_not_found
									catalog:withWriteAccessDo('set keyword',
									function()
										photo:addKeyword(keywordRegNotFound)
									end)
									-- cache registration to prevent further lookups
									regNotFoundCache[searchRegistration] = {searchRegistration = searchRegistration}
								elseif flagLookupResult == 'wrong_reg' then
									-- lookup returned wrong registration
									LrLogger:warn(photoLogFilename..' - WRONG REG: lookup returned wrong registration: '..foundRegistration..' instead of '..searchRegistration)
									countNoReg = countNoReg + 1
									flagRegFound = false
									-- mark photo with keyword wrong_reg
									catalog:withWriteAccessDo('set keyword',
									function()
										photo:addKeyword(keywordWrongReg)
									end)
								else
									-- lookup returned unknown result
									LrLogger:info(photoLogFilename..' - lookup failed')
								end
							else
								-- yes, use cached metadata
								LrLogger:info(photoLogFilename..' - using cached metadata for: '..metadataCache[searchRegistration].foundRegistration)
								countCacheHit = countCacheHit + 1
							end
						else
							-- yes, a previous lookup returned nothing useful
							countRegNotFound = countRegNotFound + 1
							flagRegFound = false
							LrLogger:warn(photoLogFilename..' - REG NOT FOUND: lookup skipped for registration '..searchRegistration..' (a previous lookup returned noting useful)')
							-- mark photo with keyword reg_not_found
							catalog:withWriteAccessDo('set keyword',
							function()
								photo:addKeyword(keywordRegNotFound)
							end)
						end
						-- check if we have a reg and user did not hit cancel
						if flagRegFound and not progressScope:isCanceled()then
							-- write metadata to photo
							catalog:withWriteAccessDo('set aircraft metadata',
							function()
								writeMetadata(photo, photoLogFilename, 'registration', metadataCache[searchRegistration].foundRegistration)
								writeMetadata(photo, photoLogFilename, 'airline', metadataCache[searchRegistration].foundAirline)
								writeMetadata(photo, photoLogFilename, 'aircraft_manufacturer', metadataCache[searchRegistration].foundAircraftManufacturer)
								writeMetadata(photo, photoLogFilename, 'aircraft_type', metadataCache[searchRegistration].foundAircraftType)
								-- set aircraft url - we overwrite this in any case
								photo:setPropertyForPlugin(_PLUGIN, 'aircraft_url', metadataCache[searchRegistration].lookupURL)
								-- remove keywords if set
								photo:removeKeyword(keywordRegNotFound)
								photo:removeKeyword(keywordWrongReg)
							end)
							-- check if user allows to write metadata to title
							if LrPrefs.prefFlagWriteTitle then
								-- create and write metadata to title
								writeTextField('title', catalog, photo, photoLogFilename)
							end
						end
					else
						-- photo has no registration
						LrLogger:info(photoLogFilename..' - no registration set')
						countNoReg = countNoReg + 1
					end
					-- update progress bar
					progressScope:setPortionComplete(countProcessed, countSelected)
				end
			end
			LrLogger:info('processed '..countProcessed..' of '..countSelected..' selected photos ('..countLookup..' web lookups, '..countRegNotFound..' regs not found, '..countCacheHit..' cache hits, '..countNoReg..' without reg)')
			progressScope:done()
		end
		LrDialogs.showBezel(messageEnd)
		LrLogger:info('>>>> done')
	end)
end

------- writeMetadata() -------------------------------------------------------
-- write metadata to db fields
function writeMetadata(photo, photoLogFilename, fieldName, fieldValue)
	-- check if field is empty
	if photo:getPropertyForPlugin(_PLUGIN, fieldName) == nil then
		-- yes, write to empty field
		photo:setPropertyForPlugin(_PLUGIN, fieldName, fieldValue)
	else
		-- check if user allows overwrite of existing metadata
		if LrPrefs.prefFlagOverwrite then
			-- yes, overwrite existing entry
			photo:setPropertyForPlugin(_PLUGIN, fieldName, fieldValue)
		else
			-- no, skip & log
			LrLogger:debug(photoLogFilename..' - '..fieldName..' contains data - skipping write')
		end
	end
end

LrTasks.startAsyncTask(AircraftMetadataImport)
