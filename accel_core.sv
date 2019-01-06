// full system architecture

module accel_core #(
  parameter int MEM_ADDR_WIDTH=16
)(
  // IO to memory
  Axi.Slave   mem_bus,
  // core interface
  Axi.Slave   core_ctrl,
  // hw accel control interface, could be NC if no control of hw accel
  Axi.Slave   accel_ctrl,
  // clk/rst for the datapath of the hw accel
  input  wire accel_clk,
  input  wire accel_rst
);

Axi #(
  .WDATA_WIDTH(MEM_ADDR_WIDTH), .RDATA_WIDTH(MEM_ADDR_WIDTH)
) accel_mem_bus(
  .aclk(mem_bus.aclk), 
  .aresetn
);

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
  .user_mem_bus(mem_bus), // Slave
  .accel_mem_bus // Slave
);

core_ctrl core_ctrl_i (
  // accelerator clk domain
  .accel_clk,
  .accel_rst,
  .preproc_accel, // Master
  .postproc_accel, // Slave
  // mem clk
  .mem_clk(mem_bus.aclk),
  .mem_rst(~mem_bus.aresetn),
  .accel_mem_bus, // Master
  // ctrl clk domain
  .ctrl_clk(core_ctrl.aclk),
  .ctrl_rst(~core_ctrl.aresetn),
  .mmap,
  .wr_mmap
);

hw_accel accel_i(
  .clk     (accel_clk),
  .rst     (accel_rst),
  .stream_i(preproc_accel), // Slave
  .stream_o(postproc_accel), // Master
  .ctrl    (accel_ctrl)
);

endmodule
