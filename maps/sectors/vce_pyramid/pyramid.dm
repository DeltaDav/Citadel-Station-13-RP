/datum/map/sector/pyramid
	id = "pyramid"
	name = "Sector - Pyramid"
	width = 192
	height = 192
	levels = list(
		/datum/map_level/sector/pyramid,
	)

/datum/map_level/sector/pyramid
	id = "pyramid"
	name = "Sector Crucis Expanse - Pyramid - Desert"
	display_name = "Pyramid"
	path = "maps/sectors/vce_pyramid/levels/pyramid.dmm"
	base_turf = /turf/simulated/floor/outdoors/beach/sand/desert
	base_area = /area/sector/pyramid/field

/datum/map_level/sector/pyramid/forrest
	id = "Solar_station_under"
	name = "Sector Crucis Expanse - Pyramid - Forrest"
	display_name = "Pyramid Moon"
	path = "maps/sectors/vce_pyramid/levels/pyramid2.dmm"
	base_turf = /turf/simulated/floor/fey/forest_grass
	base_area = /area/sector/pyramid/field
