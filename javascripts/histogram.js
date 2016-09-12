function showHistogram()
{
	var geojsonFileName = window.location.href.split('?')[1];
	var histogramDate = geojsonFileName + '.geojson.csv';
	//histogramFile = 'almost.junctions.geojson.csv';
	
	var data = new google.visualization.DataTable();
	data.addColumn('datetime', 'X');
	data.addColumn('number', geojsonFileName);
	
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open('GET', 'http://46.8.44.227/' + histogramDate + '?' + new Date().getTime(), false);
	xmlhttp.send(null);
	
	var csv = $.map($.csv.toArrays(xmlhttp.responseText), function(line){
		return [[new Date(Date.parse(line[1].replace(' ','T'))), parseInt(line[2])]];
	});
	
	data.addRows(csv);

	var options = {
	        hAxis: {
	          title: 'Time'
	        },
	        vAxis: {
	          title: 'Errors count'
	        },
	        backgroundColor: '#f1f8e9',
		explorer: {
		  maxZoomOut:2,
		  keepInBounds: true
		}
	};

	var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
	chart.draw(data, options);
}