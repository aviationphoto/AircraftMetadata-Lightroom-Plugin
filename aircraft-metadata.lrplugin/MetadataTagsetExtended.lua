--[[----------------------------------------------------------------------------
MetadataTagsetExtended.lua
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
return {
	title = 'Aircraft Metadata extended',
	id = 'ch.aviationphoto.aircraftmetadatatagset.extended',

	items = {
		{formatter = 'com.adobe.title', height_in_lines=3},
		{formatter = 'com.adobe.caption', height_in_lines=3},
		'com.adobe.separator',
		{formatter = "com.adobe.label", label = "Aircraft",},
		'ch.aviationphoto.aircraftmetadata.registration',
		'ch.aviationphoto.aircraftmetadata.airline',
		'ch.aviationphoto.aircraftmetadata.aircraft_manufacturer',
		'ch.aviationphoto.aircraftmetadata.aircraft_type',
		{formatter = 'ch.aviationphoto.aircraftmetadata.aircraft_notes', height_in_lines=3},
		'ch.aviationphoto.aircraftmetadata.aircraft_url',
		'com.adobe.separator',
		{formatter = "com.adobe.label", label = "Location",},
		'ch.aviationphoto.aircraftmetadata.airport_iata',
		--'com.adobe.separator',
		--{formatter = "com.adobe.label", label = "Flight",},
		--'ch.aviationphoto.aircraftmetadata.flight',
		--'ch.aviationphoto.aircraftmetadata.flight_from',
		--'ch.aviationphoto.aircraftmetadata.flight_to',
	}
};
