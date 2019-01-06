// handles partition, arbitration, and muxing to a 2 port BRAM

module core_mem #(
)(
  Axi.Slave  core_ctrl,
  Axi.Slave  mem_bus,
  Axi.Master preproc_data,
  Axi.Slave  postproc_data
);

endmodule