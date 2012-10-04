#!/usr/bin/env python

# Sample usage of python-fitparse to parse an activity and
# print its data records.

from __future__ import print_function
from fitparse import Activity
import re
from collections import OrderedDict

activity = Activity("tests/data/sample-activity.fit")
activity.parse()

# Records of type 'record' (I know, confusing) are the entries in an
# activity file that represent actual data points in your workout.
records = activity.get_records_by_type('record')
current_record_number = 0
dic =OrderedDict.fromkeys(["timestamp","position_lat","position_long","distance","altitude","speed","heart_rate","temperature"])
counter =0
for value in dic.keys():
    if counter != 0:
	print(';',sep='',end='')
    print(value,sep='',end='')
    counter+=1
print()
for record in records:

    # Print record number
    current_record_number += 1
    #print (" Record #%d " % current_record_number).center(40, '-')

    # Get the list of valid fields on this record
    valid_field_names = record.get_valid_field_names()
    counter = 0
    row = ''
    header = ''
    for field_name in valid_field_names:

# * timestamp: 2011-06-27 02:34:21 s
# * position_lat: 521320503 semicircles
# * position_long: -947410530 semicircles
# * distance: 88797.21 m
# * altitude: 171.8 m
# * speed: 0.0 m/s
# * heart_rate: 154 bpm
# * temperature: 22 C

        # Get the data and units for the field
        field_data = record.get_data(field_name)
        dic[str(field_name)]=field_data	
    counter =0;
    for value in dic.values():
        if counter !=0:
            print(';',sep='',end='')
        print(value,sep='',end='')
        counter+=1
    print()
