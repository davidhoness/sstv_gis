-- Table: public.sstv_tx_log

-- DROP TABLE public.sstv_tx_log;

CREATE TABLE public.sstv_tx_log
(
  "ID" bigint NOT NULL DEFAULT nextval('sstv_tx_log_seq'::regclass),
  qr_data character varying(8) NOT NULL,
  start_time timestamp without time zone NOT NULL,
  start_lat numeric NOT NULL,
  start_long numeric NOT NULL,
  stop_time timestamp without time zone NOT NULL,
  stop_lat numeric NOT NULL,
  stop_long numeric NOT NULL,
  image_no integer NOT NULL,
  CONSTRAINT "sstv_tx_log_PK_ID" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.sstv_tx_log
  OWNER TO pi;
