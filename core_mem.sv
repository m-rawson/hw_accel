// handles partition, arbitration, and muxing to a 2 port BRAM

module core_mem #(
)(
  // ctrl clk
  input wire ctrl_clk,
  input wire ctrl_rst,
  input [accel_core_pkg::MMAP_WIDTH-1:0] mmap [$bits(accel_core_pkg::MMAP_ADDR)-1:0],
  // mem clk
  Axi.Slave mem_bus,
  Axi.Slave preproc_data,
  Axi.Slave postproc_data
);

endmodule