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
log_error, log_warn, log_info = LrLogger:quick('error', 'warn', 'info')

------- startLogger() --------------------------------------------------------
-- start logger
function startLogger(functionName)
	-- check if logging enabled
	if LrPrefs.prefFlagLogging then
		LrLogger:enable('logfile')
		-- clear old logfile
		logPath = LrPathUtils.child(LrPathUtils.getStandardFilePath('documents'), 'AircraftMetadata.log')
		if LrFileUtils.exists( logPath ) then
			success, reason = LrFileUtils.delete( logPath )
			if not success then
				log_error('error deleting existing logfile!'..reason)
			end
		end
	else
		LrLogger:disable()
	end
	log_info('>>>> running '..functionName)
	log_info('Lightroom version: '..LrApplication.versionString()..' on '..LrSystemInfo.summaryString())
end

------- loadPrefs() -----------------------------------------------------------
-- load saved preferences
function loadPrefs()
	-- lookup KeywordRegNotFound
	if (LrPrefs.prefKeywordRegNotFound == nil or LrPrefs.prefKeywordRegNotFound == '') then
		LrErrors.throwUserError('Please set KeywordRegNotFound')
	end
	-- lookup KeywordWrongReg
	if (LrPrefs.prefKeywordWrongReg == nil or LrPrefs.prefKeywordWrongReg == '') then
		LrErrors.throwUserError('Please set KeywordWrongReg')
	end
	-- lookup URL
	if (LrPrefs.prefLookupUrl == nil or LrPrefs.prefLookupUrl == '') then
		LrErrors.throwUserError('Please set URL for lookup')
	end
	-- lookup RegistrationToken1
	if (LrPrefs.prefRegistrationToken1 == nil or LrPrefs.prefRegistrationToken1 == '') then
		LrErrors.throwUserError('Please set registration token 1')
	end
	-- lookup RegistrationToken2
	if (LrPrefs.prefRegistrationToken2 == nil or LrPrefs.prefRegistrationToken2 == '') then
		LrErrors.throwUserError('Please set registration token 2')
	end
	-- lookup AirlineToken1
	if (LrPrefs.prefAirlineToken1 == nil or LrPrefs.prefAirlineToken1 == '') then
		LrErrors.throwUserError('Please set airline token 1')
	end
	-- lookup AirlineToken2
	if (LrPrefs.prefAirlineToken2 == nil or LrPrefs.prefAirlineToken2 == '') then
		LrErrors.throwUserError('Please set airline token 2')
	end
	-- lookup AircraftToken1
	if (LrPrefs.prefAircraftToken1 == nil or LrPrefs.prefAircraftToken1 == '') then
		LrErrors.throwUserError('Please set aircraft token 1')
	end
	-- lookup AircraftToken2
	if (LrPrefs.prefAircraftToken2 == nil or LrPrefs.prefAircraftToken2 == '') then
		LrErrors.throwUserError('Please set aircraft token 2')
	end
	-- lookup ManufacturerToken1
	if (LrPrefs.prefManufacturerToken1 == nil or LrPrefs.prefManufacturerToken1 == '') then
		LrErrors.throwUserError('Please set manufacturer token 1')
	end
	-- lookup ManufacturerToken2
	if (LrPrefs.prefManufacturerToken2 == nil or LrPrefs.prefManufacturerToken2 == '') then
		LrErrors.throwUserError('Please set manufacturer token 2')
	end
	-- lookup Marker for Successful Search
	if (LrPrefs.prefSuccessfulSearch == nil or LrPrefs.prefSuccessfulSearch == '') then
		LrErrors.throwUserError('Please set marker for successful search')
	end
end
