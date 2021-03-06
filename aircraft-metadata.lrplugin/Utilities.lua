--[[----------------------------------------------------------------------------
Utilities.lua
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

------- Lightroom API ---------------------------------------------------------
LrApplication = import 'LrApplication'
LrFunctionContext = import 'LrFunctionContext'
LrDialogs = import 'LrDialogs'
LrFileUtils = import 'LrFileUtils'
LrPathUtils = import 'LrPathUtils'
LrHttp = import 'LrHttp'
LrProgressScope = import 'LrProgressScope'
LrErrors = import 'LrErrors'
LrStringUtils = import 'LrStringUtils'
LrSystemInfo = import 'LrSystemInfo'
LrTasks = import 'LrTasks'
LrPrefs = import 'LrPrefs'.prefsForPlugin()
LrLogger = import 'LrLogger'('AircraftMetadata')

------- startLogger() --------------------------------------------------------
-- start logger
function startLogger(functionName)
	local logPath, success, reason

	-- lookup prefFlagLogging
	if (LrPrefs.prefFlagLogging == nil) then
		LrErrors.throwUserError('Please set Logging preference')
	else
		-- check if logging enabled
		if LrPrefs.prefFlagLogging then
			LrLogger:enable('logfile')
			-- clear old logfile
			logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadata.log')
			if LrFileUtils.exists(logPath) then
				success, reason = LrFileUtils.delete(logPath)
				if not success then
					LrLogger:error('error deleting existing logfile!'..reason)
				end
			end
		else
			LrLogger:disable()
		end
		LrLogger:info('>>>> running '..functionName)
		LrLogger:info('Lightroom version: '..LrApplication.versionString()..' on '..LrSystemInfo.summaryString())
	end
end

------- setPhotoLogFilename() ------------------------------------------------
-- set photo filename for logging
function setPhotoLogFilename(photo)
	-- set photo name for logging
	-- check if we are working on a copy
	if photo:getFormattedMetadata('copyName') == nil then
		-- no, return filename only
		return photo:getFormattedMetadata('fileName')..'          '
	else
		-- yes, return filename & copy
		return photo:getFormattedMetadata('fileName')..' ('..photo:getFormattedMetadata('copyName')..')'
	end
end

------- loadPrefs() -----------------------------------------------------------
-- load saved preferences
function loadPrefs()
	LrLogger:debug('-- loading preferences ------------------------')
	-- lookup prefFlagOverwrite
	if (LrPrefs.prefFlagOverwrite == nil) then
		LrErrors.throwUserError('Please set Overwrite preference')
	else
		LrLogger:debug('prefFlagOverwrite:      '..tostring(LrPrefs.prefFlagOverwrite))
	end
	-- lookup prefFlagOverwrite
	if (LrPrefs.prefFlagWriteTitle == nil) then
		LrErrors.throwUserError('Please set write to title preference')
	else
		LrLogger:debug('prefFlagWriteTitle:     '..tostring(LrPrefs.prefFlagWriteTitle))
	end
	-- lookup KeywordRegNotFound
	if (LrPrefs.prefKeywordRegNotFound == nil or LrPrefs.prefKeywordRegNotFound == '') then
		LrErrors.throwUserError('Please set KeywordRegNotFound')
	else
		LrLogger:debug('prefKeywordRegNotFound: '..LrPrefs.prefKeywordRegNotFound)
	end
	-- lookup KeywordWrongReg
	if (LrPrefs.prefKeywordWrongReg == nil or LrPrefs.prefKeywordWrongReg == '') then
		LrErrors.throwUserError('Please set KeywordWrongReg')
	else
		LrLogger:debug('prefKeywordWrongReg:    '..LrPrefs.prefKeywordWrongReg)
	end
	-- lookup URL
	if (LrPrefs.prefLookupUrl == nil or LrPrefs.prefLookupUrl == '') then
		LrErrors.throwUserError('Please set URL for lookup')
	else
		LrLogger:debug('prefLookupUrl:          '..LrPrefs.prefLookupUrl)
	end
	-- metadata provider
	if (LrPrefs.prefMetadataProvider == nil or LrPrefs.prefMetadataProvider == '') then
		LrErrors.throwUserError('Please set metadata provider for lookup')
	else
		LrLogger:debug('prefMetadataProvider:   '..LrPrefs.prefMetadataProvider)
	end
	LrLogger:debug('-- loading preferences done -------------------')
end


------- writeTextField() --------------------------------------------------
-- create and write text to field, used for writing metadata to title or caption
function writeTextField(fieldName, catalog, photo, photoLogFilename)
	local stringOld, stringNew
	-- get old text
	stringOld = photo:getFormattedMetadata(fieldName)
	-- create new text
	stringNew = addToText(photo, '', 'registration', '')
	stringNew = addToText(photo, stringNew, 'airline', ' | ')
	stringNew = addToText(photo, stringNew, 'aircraft_manufacturer', ' | ')
	stringNew = addToText(photo, stringNew, 'aircraft_type', ' ')
	stringNew = LrStringUtils.trimWhitespace(stringNew)
	-- check if we need a update
	if stringOld == stringNew then
		-- no
		LrLogger:info(photoLogFilename..' - '..stringOld..' is fine, no update necessary')
	else
		-- yes, check if user allows overwrite of existing value
		if LrPrefs.prefFlagOverwrite or (stringOld == nil or stringOld == '') then
			catalog:withWriteAccessDo('set aircraft title',
				function()
					photo:setRawMetadata(fieldName, stringNew)
				end
			)
			LrLogger:info(photoLogFilename..' - '..fieldName..' updated: '..stringNew)
		else
			-- no, skip & log
			LrLogger:debug(photoLogFilename..' - '..fieldName..' contains data - skipping write')
		end
	end
end

------- addToText() -------------------------------------------------------
-- read metadata and add it to text, used for writing metadata to title or caption
function addToText(photo, stringInput, fieldName, stringSeperator)
	local stringOutput = ''
	local fieldValue = photo:getPropertyForPlugin(_PLUGIN, fieldName)
	-- check if metadata is nil
	if fieldValue == nil then
		-- yes, return input
		return stringInput
	else
		-- no, check if some useful metadata is set
		fieldValue = LrStringUtils.trimWhitespace(fieldValue)
		if fieldValue == '' or fieldValue == 'not set' then
			-- no, return input
			return stringInput
		else
			-- yes create & return output
			return stringInput..stringSeperator..fieldValue
		end
	end
end
