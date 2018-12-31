// full system architecture

module accel_core #(
)(
  Axi.Slave  mem_bus
  Axi.Slave  buff_stat,
  Axi.Slave  accel_ctrl
);

core_mem core_mem_i (
  .mem_bus,
  .preproc_data,
  .postproc_data
);

mem_ctrl mem_ctrl_i (
  .preproc_mem,
  .preproc_accel,
  .postproc_mem,
  .postproc_accel
);



hw_accel hw_accel_i(
  .clk,
  .rst,
  .data_i,
  .data_o,
  .ctrl
);


endmodule