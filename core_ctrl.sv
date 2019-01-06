// DMA and stream controller

module core_ctrl #(
)(
  // accelerator clk domain
  input  wire accel_clk,
  input  wire accel_rst,
  Axis.Slave  postproc_accel,
  Axis.Master preproc_accel,
  // mem clk domain
  input  wire mem_clk,
  input  wire mem_rst,
  Axi.Master  accel_mem_bus,
  // ctrl clk domain
  input  wire ctrl_clk,
  input  wire ctrl_rst,
  input [accel_core_pkg::MMAP_WIDTH-1:0] mmap [$bits(accel_core_pkg::MMAP_ADDR)-1:0],
  core_wr2mmap.Master wr_mmap
);




// CDC from mem clk to accel clk
accel_buffer #(
  PROG_SUPPORT(),
  PROG_FULL_N(),
  PROG_EMPTY_N(),
  BUFF_DEPTH(),
  BUFF_WORD()
) accel_buffer_i (
  .mem_clk,
  .mem_rst,
  .accel_clk,
  .accel_rst,
  .input_buff_full(mmap[accel_core_pkg::INPUT_BUFF_FULL][0]),
  .input_buff_empty(mmap[accel_core_pkg::INPUT_BUFF_EMPTY][0]),
  .output_buff_full(mmap[accel_core_pkg::OUTPUT_BUFF_FULL][0]),
  .output_buff_empty(mmap[accel_core_pkg::OUTPUT_BUFF_EMPTY][0]),
  .from_mem, // Slave
  .to_accel, // Master
  .from_accel, // Slave
  .to_mem // Master
);

endmodule

//  Axis.Slave  from_mem,
//  Axis.Master to_accel,
//  Axis.Slave  from_accel,
//  Axis.Master to_mem