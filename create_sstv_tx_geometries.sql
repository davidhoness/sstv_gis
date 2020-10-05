-- Table: public.sstv_tx_geometries

-- DROP TABLE public.sstv_tx_geometries;

CREATE TABLE public.sstv_tx_geometries
(
  "ID" bigint NOT NULL DEFAULT nextval('sstv_tx_geometries_seq'::regclass),
  "LOG_ID" bigint NOT NULL,
  zone_tx_land_coverage geometry NOT NULL,
  zone_tx_land_full_image_rx_possible geometry NOT NULL,
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
