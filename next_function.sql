--DROP FUNCTION next_sstv_no(numeric,numeric,numeric,numeric,integer)
CREATE OR REPLACE FUNCTION next_sstv_no(predicted_start_lat numeric, predicted_start_long numeric, predicted_stop_lat numeric, predicted_stop_long numeric, iss_horizon_dist_meters integer)
returns table
(image integer,
area_km_sq float)
language plpgsql
as
$$
declare
_predicted_point_start geometry;
_predicted_point_end geometry;
_predicted_iss_horizon_buffer_start_point geometry;
_predicted_iss_horizon_buffer_end_point geometry;
_predicted_iss_horizon_intersection_buffers_points_start_end geometry;
_antimeridian_A geometry;
_antimeridian_B geometry;
_shift_longitude boolean := false;
begin

_antimeridian_A := ST_SetSRID(ST_GeometryFromText('LINESTRING(179 90, 179 -90)'), 4326);
_antimeridian_B := ST_SetSRID(ST_GeometryFromText('LINESTRING(-179 90, -179 -90)'), 4326);

_predicted_point_start := ST_SetSRID(ST_MakePoint(predicted_start_long, predicted_start_lat), 4326);
_predicted_point_end := ST_SetSRID(ST_MakePoint(predicted_stop_long, predicted_stop_lat), 4326);

_predicted_iss_horizon_buffer_start_point := ST_Buffer(_predicted_point_start::geography, iss_horizon_dist_meters, 'quad_segs=32')::geometry;
_predicted_iss_horizon_buffer_end_point := ST_Buffer(_predicted_point_end::geography, iss_horizon_dist_meters, 'quad_segs=32')::geometry;

if ST_Intersects(_predicted_iss_horizon_buffer_start_point, _antimeridian_A) or ST_Intersects(_predicted_iss_horizon_buffer_start_point, _antimeridian_B) then
   _shift_longitude := true;
end if;

if ST_Intersects(_predicted_iss_horizon_buffer_end_point, _antimeridian_A) or ST_Intersects(_predicted_iss_horizon_buffer_end_point, _antimeridian_B) then
   _shift_longitude := true;
end if;

if _shift_longitude then
    _predicted_point_start := ST_ShiftLongitude(_predicted_point_start);
    _predicted_point_start := ST_ShiftLongitude(_predicted_point_start);
    _predicted_iss_horizon_buffer_start_point := ST_ShiftLongitude(_predicted_iss_horizon_buffer_start_point);
    _predicted_iss_horizon_buffer_end_point := ST_ShiftLongitude(_predicted_iss_horizon_buffer_end_point);
end if;

_predicted_iss_horizon_intersection_buffers_points_start_end := ST_Transform(ST_Intersection(_predicted_iss_horizon_buffer_start_point, _predicted_iss_horizon_buffer_end_point)::geometry, 4326);

return query
select sstv_tx_log.image_no as image, 
SUM(ST_Area(ST_Intersection(_predicted_iss_horizon_intersection_buffers_points_start_end, sstv_tx_geometries.iss_horizon_intersection_buffers_points_start_end)::geography)/1000.0) as area_km_sq
from sstv_tx_geometries
inner join sstv_tx_log
on sstv_tx_log."ID" = sstv_tx_geometries."LOG_ID"
where ST_Intersects(_predicted_iss_horizon_intersection_buffers_points_start_end, sstv_tx_geometries.iss_horizon_intersection_buffers_points_start_end)
group by sstv_tx_log.image_no
order by area_km_sq asc;
end;
$$