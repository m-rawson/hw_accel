// accel buffer

module accel_buffer #(
  parameter int PROG_SUPPORT=1,
  parameter int PROG_FULL_N=5,
  parameter int PROG_EMPTY_N=5,
  parameter int BUFF_DEPTH=1024,
  parameter int BUFF_WORD=32
)(
  input  wire rst,
  input  wire mem_clk,
  input  wire accel_clk,
  output wire input_buff_full,
  output wire input_buff_empty,
  output wire output_buff_full,
  output wire output_buff_empty,
  
  Axis.Slave  from_mem,
  Axis.Master to_accel,
  Axis.Slave  from_accel,
  Axis.Master to_mem
);

wire ib_full, ib_empty;
wire ib_full_p, ib_empty_p;
wire ob_full, ob_empty;
wire ob_full_p, ob_empty_p;

// from core mem, to accel
fifo #(
  .PROG_SUPPORT(PROG_SUPPORT),
  .PROG_EMPTY_N(PROG_EMPTY_N),
  .PROG_FULL_N(PROG_FULL_N),
  .BUFF_DEPTH(BUFF_DEPTH),
  .BUFF_WORD(BUFF_WORD)
)fifo_to_accel_i (
  .wr_clk(accel_clk),
  .wr_rst(rst),
  .wr_stream(from_mem),
  .prog_full(ib_full_p),
  .full(ib_full),
  .rd_clk(mem_clk),
  .rd_rst(rst),
  .rd_stream(to_accel),
  .prog_empty(ib_empty_p),
  .empty(ib_empty)
);

// from accel, to core mem
fifo #(
  .PROG_SUPPORT(PROG_SUPPORT),
  .PROG_EMPTY_N(PROG_EMPTY_N),
  .PROG_FULL_N(PROG_FULL_N),
  .BUFF_DEPTH(BUFF_DEPTH),
  .BUFF_WORD(BUFF_WORD)
)fifo_from_accel_i (
  .wr_clk(accel_clk),
  .wr_rst(rst),
  .wr_stream(from_accel),
  .prog_full(ob_full_p),
  .full(ob_full),
  .rd_clk(mem_clk),
  .rd_rst(rst),
  .rd_stream(to_mem),
  .prog_empty(ob_empty_p),
  .empty(ob_empty)
);

assign output_buff_empty = (PROG_SUPPORT) ? ob_empty_p : ob_empty;
assign output_buff_full  = (PROG_SUPPORT) ? ob_full_p  : ob_full;
assign input_buff_empty  = (PROG_SUPPORT) ? ib_empty_p : ib_empty;
assign input_buff_full   = (PROG_SUPPORT) ? ib_full_p  : ib_full;

endmodule

