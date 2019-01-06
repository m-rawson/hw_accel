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

logic [accel_core_pkg::MMAP_WIDTH-1:0] mmap [$bits(accel_core_pkg::MMAP_ADDR)-1:0];
core_wr2mmap_inf wr_mmap(); // interface for the core to write into the memory map

accel_core_mmap accel_core_mmap_i (
  .core_ctrl,
  .mmap,
  .wr_mmap
);

core_mem core_mem_i (
  // ctrl clk domain
  .ctrl_clk(core_ctrl.aclk),
  .core_rst(~core_ctrl.aresetn),
  .mmap,
  // mem clk domain
  .mem_bus, // Slave
  .preproc_data_port, // Slave
  .postproc_data_port // Slave
);

core_ctrl core_ctrl_i (
  // stream clk domain
  .stream_clk,
  .stream_rst,
  .preproc_accel, // Master
  .postproc_accel, // Slave
  // mem clk
  .preproc_mem  (preproc_data_port), // Master
  .postproc_mem (postproc_data_port), // Master
  // ctrl clk domain
  .ctrl_clk(core_ctrl.aclk),
  .ctrl_rst(~core_ctrl.aresetn),
  .mmap,
  .wr_mmap
);

hw_accel hw_accel_i(
  .clk     (stream_clk),
  .rst     (stream_rst),
  .stream_i(preproc_accel), // Slave
  .stream_o(postproc_accel), // Master
  .ctrl    (accel_ctrl)
);

endmodule
