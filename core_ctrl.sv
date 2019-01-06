// DMA and stream controller

module core_ctrl #(
)(
  input  wire stream_clk,
  input  wire stream_rst,
  Axi.Master  preproc_mem,
  Axis.Master preproc_accel,
  Axi.Master  postproc_mem,
  Axis.Slave  postproc_accel,
  input accel_core_pkg::MMAP_T mmap [accel_core_pkg::MMAP_DEPTH-1:0]
);




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
  .input_buff_full,
  .input_buff_empty,
  .output_buff_full,
  .output_buff_empty,
  .from_mem,
  .to_accel,
  .from_accel,
  .to_mem
);

endmodule

//  Axis.Slave  from_mem,
//  Axis.Master to_accel,
//  Axis.Slave  from_accel,
//  Axis.Master to_mem