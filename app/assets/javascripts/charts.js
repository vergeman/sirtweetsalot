
/* 
 *  dirty tick function, 
 *  c3 is very awkward w tick scales
 */

function get_ticks(ary, ticks) {
    var list = [];
    var min = Math.min.apply(Math, ary);
    var max = Math.max.apply(Math, ary);


    var increment = Math.round( (max-min) / ticks);
    increment = Math.max(increment, 1);
    var val = Math.min(increment, 0);

    for (i=0; i <= ticks; i++) {
        list.push(val);
        val += increment;
    }
    return list;
}

function build_queued_chart() {
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
                    values: get_ticks(queue_data_y.slice(1, queue_data_y.length), 4),
                    format: function (d) { return d; }
                },
                padding: {top: 20, bottom: 0},
                show: true
            }
        },
        padding: { top: 20, bottom:0, right: 20 },
        tooltip: { show: false},
        size: {
            height: 200,
        }
    });

    return queued_chart;
}



function build_tweetometer_chart() {
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
                    values: get_ticks(tweetometer_data_y.slice(1, tweetometer_data_y.length), 4),
                    format: function (d) { return d; }
                },
                padding: {top: 10, bottom: 0},
                show: true
            }

        },
        tooltip: { show: false},
        size: { height: 300 }
    });

    return tweetometer_chart;
}
