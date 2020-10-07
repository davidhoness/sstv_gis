delete from sstv_tx_geometries;
delete from sstv_tx_log;
alter sequence sstv_tx_geometries_seq restart;
alter sequence sstv_tx_log_seq restart;