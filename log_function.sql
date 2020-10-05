CREATE OR REPLACE FUNCTION log_sstv_tx(sstv_image_no integer, qr_code_data text, start_time text, start_lat numeric, start_long numeric, stop_time text, stop_lat numeric, stop_long numeric, iss_horizon_dist_meters integer)
returns boolean 
language plpgsql
as
$$
declare
_log_row_id bigint;
_start_location geometry;
_end_location geometry;
_zone_tx_land_coverage geometry;
_zone_tx_land_full_image_rx_possible geometry;
_iss_horizon_start geometry;
_iss_horizon_end geometry;
_antimeridian_A geometry;
_antimeridian_B geometry;
_shift_longitude boolean;
begin

select ST_SetSRID(ST_GeometryFromText('LINESTRING(179 90, 179 -90)'), 4326) into _antimeridian_A;
select ST_SetSRID(ST_GeometryFromText('LINESTRING(-179 90, -179 -90)'), 4326) into _antimeridian_B;

select ST_SetSRID(ST_MakePoint(start_long, start_lat), 4326) into _start_location;
select ST_SetSRID(ST_MakePoint(stop_long, stop_lat), 4326) into _end_location;

select ST_Transform(
ST_Buffer(ST_MakeLine(_start_location, _end_location)::geography, iss_horizon_dist_meters,'quad_segs=32')::geometry,
4326) into _zone_tx_land_coverage;

if ST_Intersects(_zone_tx_land_coverage, _antimeridian_A) or ST_Intersects(_zone_tx_land_coverage, _antimeridian_B) then
    _shift_longitude := true;
end if;

select ST_Buffer(_start_location::geography, iss_horizon_dist_meters, 'quad_segs=32')::geometry into _iss_horizon_start;
select ST_Buffer(_end_location::geography, iss_horizon_dist_meters, 'quad_segs=32')::geometry into _iss_horizon_end;

if ST_Intersects(_iss_horizon_start, _antimeridian_A) or ST_Intersects(_iss_horizon_start, _antimeridian_B) then
   _shift_longitude := true;
end if;

if ST_Intersects(_iss_horizon_end, _antimeridian_A) or ST_Intersects(_iss_horizon_end, _antimeridian_B) then
   _shift_longitude := true;
end if;

if _shift_longitude then
    select ST_Shift_Longitude(_start_location) into _start_location;
    select ST_Shift_Longitude(_end_location) into _end_location;
    select ST_Shift_Longitude(_zone_tx_land_coverage) into _zone_tx_land_coverage;
    select ST_Shift_Longitude(_iss_horizon_start) into _iss_horizon_start;
    select ST_Shift_Longitude(_iss_horizon_end) into _iss_horizon_end;
end if;

select ST_Transform(ST_Intersection(_iss_horizon_start, _iss_horizon_end)::geometry, 4326) into _zone_tx_land_full_image_rx_possible;

insert into sstv_tx_log VALUES
(default,
qr_code_data,
to_timestamp(start_time,'DD/MM/YYYY HH24:MI:SS '), 
_start_location,
to_timestamp(stop_time,'DD/MM/YYYY HH24:MI:SS'),
_end_location,
sstv_image_no)
returning "ID" into _log_row_id;

insert into sstv_tx_geometries ("LOG_ID", zone_tx_land_coverage, zone_tx_land_full_image_rx_possible) VALUES
(_log_row_id,
_zone_tx_land_coverage,
_zone_tx_land_full_image_rx_possible);
return true;
end;
$$