#!/usr/bin/env python3

# For relative imports to work in Python 3
import os, sys
sys.path.append(os.path.dirname(__file__))

import re
from math import sqrt, floor
from stream import emit, read_tuples, main



class MergeLocation:
    """
    Our problem handles 2 distinct inputs: sensor location and measurements.

    This Map-reduce job merges them both in a denormalized table, which is going to be used as input
    for all the tasks

    A simple approach would be to have both inputs share the same Key (sensor_id),
    and for each one key read all entries looking for the location and insert it in other entries with measurements.

    This works, but is a bit inneficient. Instead, I map location to the key "{sensor_id}.A" and the measurements to the key "{sensor_id}.B".
    Relying on the fact that a partitioner can be configured to send ensure both of these end on the same reducer, and the data is ordered on the reducer's input,
    I can efficiently insert the location in all measurements in a single pass.
    """
    def map():
        filename = os.environ.get("map_input_file", 'foo')

        # sensor-location.txt -> sensorId.0 -> Localtion Name
        if os.path.basename(filename) == 'sensor-location.txt':
            for sensorId, location in read_tuples(value_decoder=None):
                emit('%d.A' % (sensorId), location, key_encoder=None)

        # measurement.txt -> sensorId.1 -> (sensorId, timestamp, temperature, humidity, luz)
        else:
            for line, nothing in read_tuples(key_decoder=None):
                sensorId    = int(line[:5])
                year        = int(line[5:9])
                month       = int(line[9:11])
                day         = int(line[11:13])
                hour        = int(line[13:15])
                minute      = int(line[15:17])
                temperature = int(line[17:20])
                humidity    = int(line[20:23])
                lux         = int(line[20:23])

                emit('%d.B' % (sensorId), (sensorId, (year, month, day, hour, minute), temperature, humidity, lux), key_encoder=None)

    def reduce():
        sensor_id = None
        sensor_location = None

        for key, value in read_tuples(key_decoder=None):
            record_id, record_type = key.split('.')
            record_id = int(record_id)

            if record_type == 'A':
                # key=sensorId.A --> New location
                sensor_id = record_id
                sensor_location = value
            else:
                # key=sensorId.B --> New measurement
                if sensor_id != record_id:
                    raise Exception("Got measurement from sensor %s, but no information about it's location" % (key[0]))

                new_value = tuple([sensor_location] + list(value))
                emit(new_value, key_encoder='literal')



class Task1:
    """
    Find the location with the highest temperature for each month
    """
    month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

    def map():
        for (location, sensorId, (year, month, day, hour, minute), temperature, humidity, lux), nothing in read_tuples():
            emit(month, (temperature, location))

    def merge_records(records):
        max_temp = None
        max_temp_location = None
        for temp, location in records:
            if max_temp is None or temp > max_temp:
                max_temp = temp
                max_temp_location = location
        return (max_temp, max_temp_location)

    def combine():
        for month, records in read_tuples(group_by_key=True):
            emit(month, Task1.merge_records(records))

    def reduce():
        for month, records in read_tuples(group_by_key=True):
            max_temp, max_temp_location = Task1.merge_records(records)
            emit((Task1.month_names[month-1], max_temp_location))



class Task2:
    """
    Find the minimum/maximum temperature of each location
    """
    def map():
        for (location, sensorId, (year, month, day, hour, minute), temperature, humidity, lux), nothing in read_tuples():
            emit(location, (temperature, temperature))

    def merge_records(records):
        min_temp = None
        max_temp = None
        for record_min, record_max in records:
            if min_temp is None or record_min < min_temp:
                min_temp = record_min
            if max_temp is None or record_max > max_temp:
                max_temp = record_max
        return (min_temp, max_temp)

    def combine():
        for month, records in read_tuples(group_by_key=True):
            emit(month, Task2.merge_records(records))

    def reduce():
        for location, records in read_tuples(group_by_key=True):
            min_temp, max_temp = Task2.merge_records(records)
            emit((location, min_temp, max_temp))



class Task3:
    """
    Find the mean/stddev temperature in january and june
    The code actually computes all the month and filters out at the end.
    For each month, we store (N, sum(temp), sum(temp²)), which are enough to efficiently calculate mean and stddev
    """
    def map():
        for (location, sensorId, (year, month, day, hour, minute), temperature, humidity, lux), nothing in read_tuples():
            emit(location, {month: [1, temperature, temperature**2]})

    def merge_records(records):
        summaries = {}
        for record_summaries in records:
            for month, record_summary in record_summaries.items():
                summary = summaries.setdefault(month, [0,0,0])
                for field in range(3):
                    summary[field] += record_summary[field]
        return summaries

    def combine():
        for location, records in read_tuples(group_by_key=True):
            emit(location, Task3.merge_records(records))

    def reduce():
        for location, records in read_tuples(group_by_key=True):
            # After merging, for each month we have (count, sum, sum_sqr)
            summaries = Task3.merge_records(records)

            # Calculate mean and stddef from  (count, sum, sum_sqr)
            mean_stddev = {
                month: (
                    summary[1]/summary[0],  # mean
                    sqrt((summary[2] - summary[1]**2/summary[0]) / (summary[0])),  # stddev
                )
                for month, summary in summaries.items()
            }

            # Emit (location, jan.mean, jan.stddev, jul.mean, jul.stddev)
            missing = [float('nan'), float('nan')]
            emit((
                location,
                floor(mean_stddev.get(1, missing)[0]),
                floor(mean_stddev.get(1, missing)[1]),
                floor(mean_stddev.get(7, missing)[0]),
                floor(mean_stddev.get(7, missing)[1])
            ))


if __name__ == "__main__":
    main(merge_location=MergeLocation, task1=Task1, task2=Task2, task3=Task3)
