// asynchronous fifo

module fifo #(
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
  output logic full,
  // read clk domain
  input  wire  rd_clk,
  input  wire  rd_rst,
  Axis.Master  rd_stream,
  output logic prog_empty,
  output logic empty
);

// addr pointers
logic [$clog2(BUFF_DEPTH)-1:0] wr_addr;
logic [$clog2(BUFF_DEPTH)-1:0] rd_addr;

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

// wr status
assign full = (wr_addr === BUFF_DEPTH-1);
assign prog_full = (wr_addr === BUFF_DEPTH-1-PROG_FULL_N);

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
assign empty = (rd_addr === 0);
assign prog_empty = (rd_addr === PROG_EMPTY_N-1);


endmodule