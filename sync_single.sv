// multiflop synchronizer

module sync_single #(
  parameter int MF_SYNC_N=4
)(
  input  wire rst,
  input  wire src,
  input  wire dest_clk,
  output logic dest
);

logic [MF_SYNC_N-1:0] mf_sync;

always_ff @(posedge dest_clk) begin 
  if(rst) begin
    mf_sync <= 'h0;
	dest <= 'h0;
  end else begin
    mf_sync[0] <= src;
	for(int i=0; i<MF_SYNC_N-1; i++) begin
	  mf_sync[i+1] <= mf_sync[i];
	end
	dest <= mf_sync[MF_SYNC_N-1];
  end
end

