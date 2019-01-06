// multiflop synchronizer

module multiflop_sync #(
  parameter int SYNC_STAGES=4,
  parameter int BITWIDTH=1
)(
  input  wire src_rst,
  input  wire src_clk,
  input  wire [BITWIDTH-1:0] src,
  input  wire dest_rst,
  input  wire dest_clk,
  output wire [BITWIDTH-1:0] dest
);

logic [BITWIDTH-1:0] mf_sync [SYNC_STAGES-1:0];

// written on src clk, read on dest clk
logic [BITWIDTH-1:0] cdc_signal;

always_ff @(posedge src_clk) begin
  if(src_rst) begin
    cdc_signal <= 'h0;
  end else begin
    cdc_signal <= src;
  end
end

always_ff @(posedge dest_clk) begin 
  if(dest_rst) begin
    mf_sync <= 'h0;
  end else begin
    mf_sync[0] <= src;
	for(int i=0; i<SYNC_STAGES-1; i++) begin
	  mf_sync[i+1] <= mf_sync[i];
	end
  end
end

assign dest = mf_sync[SYNC_STAGES-1];

endmodule