// full system architecture

module accel_core #(
)(
  // IO to memory
  Axi.Slave   mem_bus,
  // core interface
  Axi.Slave   core_ctrl,
  // hw accel control interface, could be NC if no control of hw accel
  Axi.Slave   accel_ctrl,
  // clk/rst for the datapath of the hw accel
  input  wire stream_clk,
  input  wire stream_rst
);

Axi  preproc_data_port (.aclk(mem_bus.aclk), .aresetn(mem_bus.aresetn));
Axi  postproc_data_port(.aclk(mem_bus.aclk), .aresetn(mem_bus.aresetn));
Axis preproc_accel();
Axis postproc_accel();

accel_core_pkg::MMAP_T mmap [accel_core_pkg::MMAP_DEPTH-1:0];

accel_core_mmap accel_core_mmap_i (
  .core_ctrl,
  .mmap
);

core_mem core_mem_i (
  .mmap,
  .mem_bus, // Slave
  .preproc_data_port, // Slave
  .postproc_data_port // Slave
);

core_ctrl core_ctrl_i (
  .stream_clk,
  .stream_rst,
  .preproc_mem  (preproc_data_port), // Master
  .preproc_accel, // Master
  .postproc_mem (postproc_data_port), // Master
  .postproc_accel, // Slave
  .mmap // Slave
);

hw_accel hw_accel_i(
  .clk     (stream_clk),
  .rst     (stream_rst),
  .stream_i(preproc_accel), // Slave
  .stream_o(postproc_accel), // Master
  .ctrl    (accel_ctrl)
);

endmodule
