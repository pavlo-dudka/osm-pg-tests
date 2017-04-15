function showMap(geoJson, diff)
{
	var map = L.map('map').setView([49, 31], 6);
	map.addControl(new L.Control.Permalink());
	
	L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
		maxZoom: 19,
		attribution: '&copy; <a href="http://openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors'
	}).addTo(map);

	if (geoJson.indexOf("railway.dead.ends") > 0)
	{
		L.tileLayer('http://{s}.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png', {
			maxZoom: 19,
			attribution: '<a href="http://www.openrailwaymap.org/" target="_blank">OpenRailwayMap</a>'
		}).addTo(map);
	}
	if (geoJson.indexOf("decommunization") > 0)
	{
		var data = '{"version": "1.3.1","layers": [{"type": "cartodb", "options": {"cartocss_version": "2.1.1", "cartocss": "#decommunization{line-color: #F22; line-width: 5; line-opacity: 0.5;}","sql": "select * from decommunization"}}]}';
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open('POST', 'http://dudka.cartodb.com/api/v1/map', false);
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.send(data);
		var response = eval('(' + xmlhttp.responseText + ')');

		L.tileLayer('https://dudka.cartodb.com/api/v1/map/' + response.layergroupid + '/0/{z}/{x}/{y}.png', {
			maxZoom: 19
		}).addTo(map);
	}
	if (geoJson.indexOf("place.districts") > 0)
	{
		var data = '{"version": "1.3.1","layers": [{"type": "cartodb", "options": {"cartocss_version": "2.1.1", "cartocss": "#all_t{line-color: #F22; line-width: 1; line-opacity: 1;}","sql": "select * from all_t where koatuu::text not like \'%00000000\'"}}]}';
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open('POST', 'http://dudka.cartodb.com/api/v1/map', false);
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.send(data);
		var response = eval('(' + xmlhttp.responseText + ')');

		L.tileLayer('https://dudka.cartodb.com/api/v1/map/' + response.layergroupid + '/0/{z}/{x}/{y}.png', {
			maxZoom: 19
		}).addTo(map);
	}
	
	showGeoJson(map, geoJson, diff);
}

function showGeoJson(map, geoJson, diff)
{
	var xmlhttp = new XMLHttpRequest();
	if (typeof(diff) != "undefined")
		geoJson = "http://51.15.73.151:8080/errors/" + geoJson.substring(8).replace('.geojson','') + "/since/"+ diff;
	xmlhttp.open('GET', geoJson, false);
	xmlhttp.send(null);
	
	var myGeoJson = eval('(' + xmlhttp.responseText + ')');	
	if (myGeoJson.features.length == 1);
	else if (myGeoJson.features[0].geometry.type == 'Point' || myGeoJson.no_markers == 'true')
	{
		var geoJsonLayer = L.geoJson(myGeoJson, {
			onEachFeature: function (feature, layer) {
			layer.bindPopup(popupHtml(feature, myGeoJson.errorDescr));
			}
		});
		
		var markers = L.markerClusterGroup();
		markers.addLayer(geoJsonLayer);
		map.addLayer(markers);
	}
	else
	{
		var myGeoJsonPoints = eval('(' + xmlhttp.responseText + ')');	
		for (var i = 0; i < myGeoJson.features.length - 1; i++)
		{			
			myGeoJsonPoints.features[i].geometry.type = 'Point';
			if (myGeoJson.features[0].geometry.type == 'GeometryCollection')
			{
				myGeoJsonPoints.features[i].geometry.coordinates = myGeoJson.features[i].geometry.geometries[0].coordinates;
				myGeoJson.features[i].geometry.geometries = myGeoJson.features[i].geometry.geometries.slice(1);
			}
			else if (myGeoJsonPoints.features[i].geometry.coordinates[0][0] instanceof Array)
				myGeoJsonPoints.features[i].geometry.coordinates = myGeoJson.features[i].geometry.coordinates[0][Math.floor(myGeoJson.features[i].geometry.coordinates[0].length / 2)];
			else
				myGeoJsonPoints.features[i].geometry.coordinates = myGeoJson.features[i].geometry.coordinates[Math.floor(myGeoJson.features[i].geometry.coordinates.length / 2)];
		}
		
		var geoJsonLayer = L.geoJson(myGeoJson, {
			onEachFeature: function (feature, layer) {
			layer.bindPopup(popupHtml(feature, myGeoJson.errorDescr));
			}
		});

		
		map.addLayer(geoJsonLayer);

		var geoJsonLayer2 = L.geoJson(myGeoJsonPoints, {
			onEachFeature: function (feature, layer) {
			layer.bindPopup(popupHtml(feature, myGeoJsonPoints.errorDescr));
			}
		});

		var markers = L.markerClusterGroup();
		markers.addLayer(geoJsonLayer2);
		map.addLayer(markers);
	}	
}

function popupHtml(feature, errorDescr)
{
	var result = '';
	if (typeof(feature.properties.error) != "undefined")
	{
		result += '<center><b><font color="FF0000">' + feature.properties.error + '</font></b></center>';
	}
	else if (typeof(errorDescr) != "undefined")
	{
		result += '<center><b><font color="FF0000">' + errorDescr + '</font></b></center>';
	}
	result += '<table>';
	if (typeof(feature.properties.josm) != "undefined")
	{
		var objects = feature.properties.josm.split(',');
		for(var i=0; i < objects.length; i++)
		{
			if (objects[i].indexOf('n') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			if (objects[i].indexOf('w') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			if (objects[i].indexOf('r') == 0)
				objects[i] = '<a href="http://www.openstreetmap.org/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
		}
		result += '<tr><th>Related objects:</th><td>' + objects.join(', ') + '</td></tr>';
	}
	if (typeof(feature.properties.name) != "undefined")
	{
		result += '<tr><th>Name:</th><td>' + feature.properties.name + '</td></tr>';
	}
	if (typeof(feature.properties.nameuk) != "undefined")
	{
		result += '<tr><th>Name(ukr):</th><td>' + feature.properties.nameuk + '</td></tr>';
	}
	if (typeof(feature.properties.relationtags) != "undefined")
	{
		var tvs = feature.properties.relationtags.split('&');
		for(var i=0; i < tvs.length; i++)
		{
			var tv = tvs[i].split('|');
			result += '<tr><th>Relation ' + tv[0] +':</th><td>' + tv[1] + '</td></tr>';
		}
	}
	if (typeof(feature.properties.membertags) != "undefined")
	{
		var tv = feature.properties.membertags.split('|');
		result += '<tr><th>Member ' + tv[0] +':</th><td>' + tv[1] + '</td></tr>';
	}
	if (typeof(feature.properties.memberrole) != "undefined")
	{
		result += '<tr><th>Member Role:</th><td>' + feature.properties.memberrole + '</td></tr>';
	}
	if (typeof(feature.properties.addrhousenumber) != "undefined")
	{
		result += '<tr><th>House number:</th><td>' + feature.properties.addrhousenumber + '</td></tr>';
	}
	if (typeof(feature.properties.cur_district) != "undefined")
	{
		result += '<tr><th>Current district:</th><td>' + feature.properties.cur_district + '</td></tr>';
	}
	if (typeof(feature.properties.exp_district) != "undefined")
	{
		result += '<tr><th>Expected district:</th><td>' + feature.properties.exp_district + '</td></tr>';
	}
	if (typeof(feature.properties.region) != "undefined")
	{
	        if (feature.properties.region.substring(0,2) == "UA")
			result += '<tr><th>Region:</th><td><a href="http://peirce.zkir.ru/qa/' + feature.properties.region + '">' + feature.properties.region + '</a></td></tr>';
		else
			result += '<tr><th>Region:</th><td>' + feature.properties.region + '</td></tr>';
	}
	if (typeof(feature.properties.city) != "undefined")
	{
		result += '<tr><th>City:</th><td>' + feature.properties.city + '</td></tr>';
	}
	if (typeof(feature.properties.population) != "undefined")
	{
		result += '<tr><th>Population:</th><td>' + feature.properties.population + '</td></tr>';
	}
	if (typeof(feature.properties.koatuu) != "undefined")
	{
		result += '<tr><th>KOATUU:</th><td>' + feature.properties.koatuu + '</td></tr>';
	}
	if (typeof(feature.properties.length) != "undefined")
	{
		result += '<tr><th>Length (km):</th><td>' + feature.properties.length + '</td></tr>';
	}
	if (typeof(feature.properties.level) != "undefined")
	{
		result += '<tr><th>Level:</th><td>' + feature.properties.level + '</td></tr>';
	}
	if (typeof(feature.properties.address) != "undefined")
	{
		result += '<tr><th>Address:</th><td>' + feature.properties.address + '</td></tr>';
	}
	if (typeof(feature.properties.old_name) != "undefined")
	{
		result += '<tr><th>Old name:</th><td>' + feature.properties.old_name + '</td></tr>';
	}
	if (typeof(feature.properties.new_name) != "undefined")
	{
		result += '<tr><th>New name:</th><td>' + feature.properties.new_name + '</td></tr>';
	}
	if (typeof(feature.properties.levels) != "undefined")
	{
		result += '<tr><th>Building Levels:</th><td>' + feature.properties.levels + '</td></tr>';
	}
	if (typeof(feature.properties.NumberOfRoads) != "undefined")
	{
		result += '<tr><th>Roads count:</th><td>' + feature.properties.NumberOfRoads + '</td></tr>';
	}
	if (feature.geometry == 'Point')
		result += '<tr><th>Coordinates:</th><td>' + feature.geometry.coordinates + '</td></tr>';
	result = result + '</table>';
	
	result += '<input type="button" value="Edit in JOSM" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + feature.geometry.coordinates + '\')">';
	result += '<input type="button" value="Edit in Browser" onClick="openInBrowser(\'' + feature.geometry.coordinates + '\')">';
	
	return result;
}

function showTable(geoJson, diff)
{
	document.write('<table class="sortable">');

	var xmlhttp = new XMLHttpRequest();
	if (typeof(diff) != "undefined")
		geoJson = "http://51.15.73.151:8080/errors/" + geoJson.substring(8).replace('.geojson','') + "/since/"+ diff;
	xmlhttp.open('GET', geoJson, false);
	xmlhttp.send(null);
	var mypoints = eval('(' + xmlhttp.responseText + ')');
	
	for(j = 0; j < mypoints.features.length - 1; j++)
	{
		var feature = mypoints.features[j];
		if (j == 0)
		{
			document.write('<tr>');
			document.write('<th class="sorttable_sorted">#<span id="sorttable_sortfwdind">' + (stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;') + '</span></th>');
			document.write('<th>Josm</th>');
			
			if (typeof(feature.properties.name) != "undefined")
			{
				document.write('<th>Name</th>');
			}
			if (typeof(feature.properties.nameuk) != "undefined")
			{
				document.write('<th>Name:uk</th>');
			}
			if (typeof(feature.properties.relationtags) != "undefined")
			{
				document.write('<th>Relation</th>');
				if (feature.properties.relationtags.indexOf('&') > -1)
					document.write('<th>Relation</th>');
			}
			if (typeof(feature.properties.membertags) != "undefined")
			{
				document.write('<th>Member</th>');
			}
			if (typeof(feature.properties.memberrole) != "undefined")
			{
				document.write('<th>Member Role</th>');
			}
			if (typeof(feature.properties.addrhousenumber) != "undefined")
			{
				document.write('<th>House No.</th>');
			}
			if (typeof(feature.properties.cur_district) != "undefined")
			{
				document.write('<th>Current district</th>');
			}
			if (typeof(feature.properties.exp_district) != "undefined")
			{
				document.write('<th>Expected district</th>');
			}
			if (typeof(feature.properties.region) != "undefined")
			{
				document.write('<th>Region</th>');
			}
			if (typeof(feature.properties.city) != "undefined")
			{
				document.write('<th>City</th>');
			}
			if (typeof(feature.properties.population) != "undefined")
			{
				document.write('<th>Population</th>');
			}
			if (typeof(feature.properties.koatuu) != "undefined")
			{
				document.write('<th>KOATUU</th>');
			}
			if (typeof(feature.properties.length) != "undefined")
			{
				document.write('<th>Length (km)</th>');
			}
			if (typeof(feature.properties.level) != "undefined")
			{
				document.write('<th>Level</th>');
			}
			if (typeof(feature.properties.address) != "undefined")
			{
				document.write('<th>Address</th>');
			}
			if (typeof(feature.properties.old_name) != "undefined")
			{
				document.write('<th>Old name</th>');
			}
			if (typeof(feature.properties.new_name) != "undefined")
			{
				document.write('<th>New name</th>');
			}
			if (typeof(feature.properties.levels) != "undefined")
			{
				document.write('<th>Building Levels</th>');
			}
			if (typeof(feature.properties.NumberOfRoads) != "undefined")
			{
				document.write('<th>Roads count</th>');
			}
			
			if (typeof(feature.properties.josm) != "undefined")
			{
				document.write('<th>Objects</th>');
			}
			document.write('</tr>');
		}
		
		document.write('<tr title="');
		if (typeof(feature.properties.error) != "undefined")
		{
			document.write(feature.properties.error);
		}
		else if (typeof(mypoints.errorDescr) != "undefined")
		{
			document.write(mypoints.errorDescr);
		}
		document.write('">');
		document.write('<td>' + (j+1) + '</td>');
		document.write('<td><input type="button" value="Edit" onClick="openInJosm(\'' + feature.properties.josm + '\',\'' + feature.geometry.coordinates + '\')"></td>');
		
		if (typeof(feature.properties.name) != "undefined")
		{
			document.write('<td>' + feature.properties.name + '</td>');
		}
		if (typeof(feature.properties.nameuk) != "undefined")
		{
			document.write('<td>' + feature.properties.nameuk + '</td>');
		}
		if (typeof(feature.properties.relationtags) != "undefined")
		{
			var tvs = feature.properties.relationtags.split('&');
			for(var i=0; i < Math.min(tvs.length,2); i++)
			{
				var tv = tvs[i].split('|');
				document.write('<td>' + tv[1] + '</td>');
			}
		}
		if (typeof(feature.properties.membertags) != "undefined")
		{
			var tv = feature.properties.membertags.split('|');
			document.write('<td>' + tv[1] + '</td>');
		}
		if (typeof(feature.properties.memberrole) != "undefined")
		{
			document.write('<td>' + feature.properties.memberrole + '</td>');
		}
		if (typeof(feature.properties.addrhousenumber) != "undefined")
		{
			document.write('<td>' + feature.properties.addrhousenumber + '</td>');
		}
		if (typeof(feature.properties.cur_district) != "undefined")
		{
			document.write('<td>' + feature.properties.cur_district + '</td>');
		}
		if (typeof(feature.properties.exp_district) != "undefined")
		{
			document.write('<td>' + feature.properties.exp_district + '</td>');
		}
		if (typeof(feature.properties.region) != "undefined")
		{
			if (feature.properties.region.substring(0,2) == "UA")
				document.write('<td><a href="http://peirce.zkir.ru/qa/' + feature.properties.region + '">' + feature.properties.region + '</a></td>');
			else
				document.write('<td>' + feature.properties.region + '</td>');
		}
		if (typeof(feature.properties.city) != "undefined")
		{
			document.write('<td>' + feature.properties.city + '</td>');
		}
		if (typeof(feature.properties.population) != "undefined")
		{
			document.write('<td>' + feature.properties.population + '</td>');
		}
		if (typeof(feature.properties.koatuu) != "undefined")
		{
			document.write('<td>' + feature.properties.koatuu + '</td>');
		}
		if (typeof(feature.properties.length) != "undefined")
		{
			document.write('<td>' + feature.properties.length + '</td>');
		}
		if (typeof(feature.properties.level) != "undefined")
		{
			document.write('<td>' + feature.properties.level + '</td>');
		}
		if (typeof(feature.properties.address) != "undefined")
		{
			document.write('<td>' + feature.properties.address + '</td>');
		}
		if (typeof(feature.properties.old_name) != "undefined")
		{
			document.write('<td>' + feature.properties.old_name + '</td>');
		}
		if (typeof(feature.properties.new_name) != "undefined")
		{
			document.write('<td>' + feature.properties.new_name + '</td>');
		}
		if (typeof(feature.properties.levels) != "undefined")
		{
			document.write('<td>' + feature.properties.levels + '</td>');
		}
		if (typeof(feature.properties.NumberOfRoads) != "undefined")
		{
			document.write('<td>' + feature.properties.NumberOfRoads + '</td>');
		}

		if (typeof(feature.properties.josm) != "undefined")
		{
			var objects = feature.properties.josm.split(',');
			for(var i=0; i < objects.length; i++)
			{
				if (objects[i].indexOf('n') == 0)
					objects[i] = '<a href="http://www.openstreetmap.org/node/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
				if (objects[i].indexOf('w') == 0)
					objects[i] = '<a href="http://www.openstreetmap.org/way/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
				if (objects[i].indexOf('r') == 0)
					objects[i] = '<a href="http://www.openstreetmap.org/relation/' + objects[i].substring(1) + '" target="_blank">' + objects[i] + '</a>';
			}
			document.write('<td>' + objects.join(', ') + '</td>');
		}
		
		document.write('</tr>');
	}
	
	document.write('</table>');
}

function openInJosm(load, point)
{
    if (load != "undefined")
    {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open('GET', josmLoadObject(load), false);
        xmlhttp.send(null);
            
        var xmlhttp2 = new XMLHttpRequest();
        xmlhttp2.open('GET', josmZoomToPoint(point), false);
        xmlhttp2.send(null);
	}
    else
    {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open('GET', josmZoomAndLoadToPoint(point), false);
        xmlhttp.send(null);
    }
}

function openInBrowser(point)
{
	var coords = point.split(',');
	var win=window.open('http://www.openstreetmap.org/edit?#map=19/' + coords[1] + '/' + coords[0], '_blank');
	win.focus();
}

function josmLoadObject(load)
{
	return 'http://localhost:8111/load_object?new_layer=false&objects=' + load;
}

function josmZoomToPoint(point)
{
	var coords = point.split(',');
	var left = coords[0]-0.001;
	var right = Number(coords[0])+0.001;
	var top = coords[1]-0.001;
	var bottom = Number(coords[1])+0.001;
	
	return 'http://localhost:8111/zoom?left=' + left + '&right=' + right + '&top=' + top + '&bottom=' + bottom;
}

function josmZoomAndLoadToPoint(point)
{
	var coords = point.split(',');
	var left = coords[0]-0.001;
	var right = Number(coords[0])+0.001;
	var bottom = coords[1]-0.001;
	var top = Number(coords[1])+0.001;
    	
	return 'http://localhost:8111/load_and_zoom?left=' + left + '&right=' + right + '&top=' + top + '&bottom=' + bottom;
}