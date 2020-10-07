#!/usr/bin/python3

import psycopg2
import csv
import random

conn = psycopg2.connect('dbname=test')
global cur
cur = conn.cursor()

iss_horizon = 2292771

def insert_row(image_no, qr_code_data, start_time, start_lat, start_long, stop_time, stop_lat, stop_long, iss_horizon_dist_meters):
    sql = """
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
    print(sql % values)
    cur.execute(sql, values)
    return cur.fetchall()

def next_image(start_lat, start_long, stop_lat, stop_long, iss_horizon_dist_meters):
    sql = """
    select * from next_sstv_no(
    predicted_start_lat => %s::numeric,
    predicted_start_long => %s::numeric,
    predicted_stop_lat => %s::numeric,
    predicted_stop_long => %s::numeric,
    iss_horizon_dist_meters => %s::integer);
    """

    values = (float(start_lat), float(start_long), float(stop_lat), float(stop_long), iss_horizon_dist_meters)
    print(sql % values)
    cur.execute(sql, values)
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
        next_image_results = next_image(row['Start Lat'], row['Start Long'], row['Stop Lat'], row['Stop Long'], iss_horizon)
        image_dict = {str(key): 0 for key in range(1, 13)}
        for rowA in next_image_results:
            image_dict[str(rowA[0])] = rowA[1]
        print(image_dict)
        min_value = min(image_dict.values())
        selected = random.choice(list(filter(lambda x: x[1]==min_value, image_dict.items())))
        next_image_no = selected[0]
        print(next_image_no)

        results = insert_row(int(next_image_no), row['UID'], row['Start Time'], row['Start Lat'], row['Start Long'], row['Stop Time'], row['Stop Lat'], row['Stop Long'], iss_horizon)
        if results[0][0] == True:
            print('Insert sucess')
            conn.commit()
        else:
            print('ERROR')

        #input("Press a key to continue")

conn.close()
