
var queued_chart = c3.generate({    
    bindto: '#queued-chart',
    data: {
        x: 'x',
        columns: [
            queue_data_x,
            queue_data_y
        ]
    },
    axis: {
        x: {
            type: 'timeseries',
            tick: {
                format: '%m-%d',
                fit: true
            }
        },
        y: {
            min: 0,
            tick: { 
                count: 3,
                format: function (d) { return Math.round(d / 10) * 10; }
            },
            padding: {top: 10, bottom: 0},
            show: true
        }
    },
    padding: { right: 20 },
    tooltip: { show: false},
    size: { 
        height: 200,
    }
});





var tweetometer_chart = c3.generate({    
    bindto: '#tweetometer-chart',
    data: {
        x: 'x',
        columns: [
            tweetometer_data_x,
            tweetometer_data_y
        ],
        colors : {'TWEETS' : '#f39c12'}
    },
    axis: {
        x: {
            type: 'timeseries',
            tick: {
                format: '%m-%d',
                fit: true
            }
        },
        y: {
            min: 0,
            tick: { 
                count: 3,
                format: function (d) { return Math.round(d / 10) * 10; }
            },
            padding: {top: 10, bottom: 0},
            show: true
        }
    },
    tooltip: { show: false},
    size: { height: 300 }
});


