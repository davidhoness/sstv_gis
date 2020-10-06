#!/usr/bin/python3

import psycopg2
import csv
import random

conn = psycopg2.connect('dbname=test')
global cur
cur = conn.cursor()

iss_horizon = 2292771

def insert_row(image_no, qr_code_data, start_time, start_lat, start_long, stop_time, stop_lat, stop_long, iss_horizon_dist_meters):
    insert_query = """
    select log_sstv_tx(
    sstv_image_no => %s::integer,
    qr_code_data => %s::text,
    start_time => %s::text,
    start_lat => %s::numeric,
    start_long => %s::numeric,
    stop_time => %s::text,
    stop_lat => %s::numeric,
    stop_long => %s::numeric,
    iss_horizon_dist_meters => %s::integer);
    """

    values = (image_no, qr_code_data, start_time, float(start_lat), float(start_long), stop_time, float(stop_lat), float(stop_long), iss_horizon_dist_meters)
    print(insert_query % values)
    cur.execute(insert_query, values)
    return cur.fetchall()


#results = insert_row(1, "9806a6b1", "24/04/19 11:16:30", 14.0366, -101.6985, "24/04/19 11:18:39", 20.3463, -96.5828, iss_horizon)

#for result in results:
#    print(result)



with open('experiment_data.csv', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    rows = list(csv_reader)
    totalrows = len(rows)
    print(totalrows)

    for row in rows:
        pic_no = random.randint(1,12)
        results = insert_row(pic_no, row['UID'], row['Start Time'], row['Start Lat'], row['Start Long'], row['Stop Time'], row['Stop Lat'], row['Stop Long'], iss_horizon)
        if results[0][0] == True:
            print('Insert sucess')
            conn.commit()
        else:
            print('ERROR')

conn.close()
