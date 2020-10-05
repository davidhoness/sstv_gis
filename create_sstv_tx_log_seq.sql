-- Sequence: public.sstv_tx_log_seq

-- DROP SEQUENCE public.sstv_tx_log_seq;

CREATE SEQUENCE public.sstv_tx_log_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 0
  START 1
  CACHE 0;
ALTER TABLE public.sstv_tx_log_seq
  OWNER TO pi;
