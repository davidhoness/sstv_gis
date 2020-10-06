-- Table: public.sstv_tx_geometries

-- DROP TABLE public.sstv_tx_geometries;

CREATE TABLE public.sstv_tx_geometries
(
  "ID" bigint NOT NULL DEFAULT nextval('sstv_tx_geometries_seq'::regclass),
  "LOG_ID" bigint NOT NULL,
  point_start geometry NOT NULL,
  point_end geometry NOT NULL,
  line_points_start_end geometry NOT NULL,
  iss_horizon_buffer_line_points_start_end geometry NOT NULL, -- ISS horizon land coverage for this image
  iss_horizon_intersection_buffers_points_start_end geometry NOT NULL, -- Zone where full image reception is possible
  longitude_shifted boolean NOT NULL,
  CONSTRAINT "sstv_tx_geometries_PK_ID" PRIMARY KEY ("ID"),
  CONSTRAINT "sstv_tx_geometries_FK_LOG_ID" FOREIGN KEY ("LOG_ID")
      REFERENCES public.sstv_tx_log ("ID") MATCH SIMPLE
      ON UPDATE RESTRICT ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.sstv_tx_geometries
  OWNER TO pi;
COMMENT ON COLUMN public.sstv_tx_geometries.iss_horizon_buffer_line_points_start_end IS 'ISS horizon land coverage for this image';
COMMENT ON COLUMN public.sstv_tx_geometries.iss_horizon_intersection_buffers_points_start_end IS 'Zone where full image reception is possible';

