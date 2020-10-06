CREATE OR REPLACE FUNCTION log_sstv_tx(sstv_image_no integer, qr_code_data text, start_time text, start_lat numeric, start_long numeric, stop_time text, stop_lat numeric, stop_long numeric, iss_horizon_dist_meters integer)
returns boolean 
language plpgsql
as
$$
declare
_log_row_id bigint;
_point_start geometry;
_point_end geometry;
_line_points_start_end geometry;
_iss_horizon_buffer_line_points_start_end geometry;
_iss_horizon_buffer_start_point geometry;
_iss_horizon_buffer_end_point geometry;
_iss_horizon_intersection_buffers_points_start_end geometry;
_antimeridian_A geometry;
_antimeridian_B geometry;
_shift_longitude boolean := false;
begin

insert into sstv_tx_log VALUES
(default, 
qr_code_data, 
to_timestamp(start_time,'DD/MM/YYYY HH24:MI:SS '), start_lat, start_long,
to_timestamp(stop_time,'DD/MM/YYYY HH24:MI:SS'), stop_lat, stop_long,
sstv_image_no)
returning "ID" into _log_row_id;

_antimeridian_A := ST_SetSRID(ST_GeometryFromText('LINESTRING(179 90, 179 -90)'), 4326);
_antimeridian_B := ST_SetSRID(ST_GeometryFromText('LINESTRING(-179 90, -179 -90)'), 4326);

_point_start := ST_SetSRID(ST_MakePoint(start_long, start_lat), 4326);
_point_end := ST_SetSRID(ST_MakePoint(stop_long, stop_lat), 4326);

_line_points_start_end := ST_MakeLine(_point_start, _point_end);

_iss_horizon_buffer_line_points_start_end := ST_Transform(ST_Buffer(_line_points_start_end::geography, iss_horizon_dist_meters,'quad_segs=32')::geometry, 4326);

if ST_Intersects(_iss_horizon_buffer_line_points_start_end, _antimeridian_A) or ST_Intersects(_iss_horizon_buffer_line_points_start_end, _antimeridian_B) then
    _shift_longitude := true;
end if;

_iss_horizon_buffer_start_point := ST_Buffer(_point_start::geography, iss_horizon_dist_meters, 'quad_segs=32')::geometry;
_iss_horizon_buffer_end_point := ST_Buffer(_point_end::geography, iss_horizon_dist_meters, 'quad_segs=32')::geometry;

if ST_Intersects(_iss_horizon_buffer_start_point, _antimeridian_A) or ST_Intersects(_iss_horizon_buffer_start_point, _antimeridian_B) then
   _shift_longitude := true;
end if;

if ST_Intersects(_iss_horizon_buffer_end_point, _antimeridian_A) or ST_Intersects(_iss_horizon_buffer_end_point, _antimeridian_B) then
   _shift_longitude := true;
end if;

if _shift_longitude then
    _point_start := ST_ShiftLongitude(_point_start);
    _point_end := ST_ShiftLongitude(_point_end);
    _line_points_start_end := ST_ShiftLongitude(_line_points_start_end);
    _iss_horizon_buffer_line_points_start_end := ST_ShiftLongitude(_iss_horizon_buffer_line_points_start_end);
    _iss_horizon_buffer_start_point := ST_ShiftLongitude(_iss_horizon_buffer_start_point);
    _iss_horizon_buffer_end_point := ST_ShiftLongitude(_iss_horizon_buffer_end_point);
end if;

_iss_horizon_intersection_buffers_points_start_end := ST_Transform(ST_Intersection(_iss_horizon_buffer_start_point, _iss_horizon_buffer_end_point)::geometry, 4326);

insert into sstv_tx_geometries VALUES
(default, 
_log_row_id,
_point_start,
_point_end,
_line_points_start_end,
_iss_horizon_buffer_line_points_start_end,
_iss_horizon_intersection_buffers_points_start_end,
_shift_longitude);

return true;
end;
$$