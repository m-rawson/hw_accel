// asynchronous fifo
// only powers of two supported

module fifo #(
  parameter int PROG_SUPPORT=1,
  parameter int PROG_FULL_N=5,
  parameter int PROG_EMPTY_N=5,
  parameter int BUFF_DEPTH=1024,
  parameter int BUFF_WORD=32
)(
  // write clk domain
  input  wire  wr_clk,
  input  wire  wr_rst,
  Axis.Slave   wr_stream,
  output logic prog_full,
  output wire full,
  // read clk domain
  input  wire  rd_clk,
  input  wire  rd_rst,
  Axis.Master  rd_stream,
  output logic prog_empty,
  output wire empty
);

// addr pointers
logic [$clog2(BUFF_DEPTH)-1:0] wr_addr, wr_addr_gray, wr_addr_gray_next, wr_addr_gray_sync;
logic [$clog2(BUFF_DEPTH)-1:0] wr_addr_prog, wr_addr_gray_prog;
logic [$clog2(BUFF_DEPTH)-1:0] rd_addr, rd_addr_gray, rd_addr_gray_sync;
logic [$clog2(BUFF_DEPTH)-1:0] rd_addr_prog, rd_addr_gray_prog;

// memory
logic [BUFF_WORD-1:0] buff [BUFF_DEPTH-1:0];

// wr addr
always_ff @(posedge wr_clk) begin
  if(wr_rst) begin
    wr_addr <= 'h0;
  end else begin
    wr_addr <= wr_addr + wr_stream.ok;
  end
end

// wr data
always_ff @(posedge wr_clk) begin
  if (wr_stream.ok) begin
    buff[wr_addr] <= wr_stream.data;
	wr_strem.ready <= ~(wr_rst | full);
  end
end

// wr status/clock domain
// full if one more write would become rd addr
assign full = (wr_addr_gray_next == rd_addr_gray_sync);

// rd addr
always_ff @(posedge rd_clk) begin
  if(rd_rst) begin
    rd_addr <= 'h0;
  end else begin
    rd_addr <= rd_addr + rd_stream.ok;
  end
end

// rd data
always_ff @(posedge rd_clk) begin
  if (rd_stream.ok) begin
    rd_stream.data <= buff[rd_addr]; 
    rd_stream.valid = ~(rd_rst | empty);
  end
end

// rd status
// empty when addr equals
assign empty = (rd_addr_gray == wr_addr_gray_sync);

// gray coding
assign rd_addr_gray = rd_addr ^ (rd_addr>>1);
assign wr_addr_gray = wr_addr ^ (wr_addr>>1);
assign wr_addr_gray_next = (wr_addr+'b1) ^ ((wr_addr+'b1)>>1);

always_comb begin
  if(PROG_SUPPORT) begin
    // wr clk domain
	wr_addr_prog = wr_addr + PROG_FULL_N + 'b1; // plus 1 from non-prog case
    wr_addr_gray_prog = wr_addr_prog ^ (wr_addr_prog>>1);
    prog_full = (wr_addr_gray_prog == rd_addr_gray_sync);
    // rd clk domain
    rd_addr_prog = rd_addr + PROG_EMPTY_N;
    rd_addr_gray_prog = rd_addr_prog ^ (rd_addr_prog>>1);
    prog_empty = (rd_addr_gray_prog == wr_addr_gray_sync);
  end
end

// CDC fifo status single bit signals
multiflop_sync #(
  .SYNC_STAGES(2),
  .BITWIDTH($clog2(BUFF_DEPTH))
) rd_addr_sync_i (
  .src_rst(rd_rst),
  .src_clk(rd_clk),
  .src(rd_addr_gray),
  .dest_rst(wr_rst),
  .dest_clk(wr_clk),
  .dest({rd_addr_gray_sync})
);

multiflop_sync #(
  .SYNC_STAGES(2),
  .BITWIDTH($clog2(BUFF_DEPTH))
) wr_addr_sync_i (
  .src_rst(wr_rst),
  .src_clk(wr_clk),
  .src({wr_addr_gray}),
  .dest_rst(rd_rst),
  .dest_clk(rd_clk),
  .dest({wr_addr_gray_sync})
);


endmodule