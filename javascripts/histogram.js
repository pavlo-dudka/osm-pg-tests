function showHistogram()
{
	var geojsonFileName = window.location.href.split('?')[1];
	var histogramDataFile = geojsonFileName + '.geojson.csv';
	
	var data = new google.visualization.DataTable();
	data.addColumn('datetime', 'X');
	data.addColumn('number', geojsonFileName);
	
	var xmlhttp1 = new XMLHttpRequest();
	xmlhttp1.open('GET', 'http://51.15.73.151/csv/version?' + new Date().getTime(), false);
	xmlhttp1.send(null);
	
	var xmlhttp2 = new XMLHttpRequest();
	xmlhttp2.open('GET', 'http://51.15.73.151/csv/' + histogramDataFile + '?' + Date.parse(xmlhttp1.responseText.slice(0, -1)), false);
	xmlhttp2.send(null);
	
	var csv = xmlhttp2.responseText.split('\n')
		.filter(function(line){
			return line !== "";
		})
		.map(function(line){
			var fields = line.replace(' ','T').replace('\r','').split(',');
			return [new Date(Date.parse(fields[0])), parseInt(fields[1])];
		}
	);
	
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
