// generic delay line

module delay #(
  parameter int DELAY=1,
  parameter int BITWIDTH=1
)(
  input       clk,
  input       rst,
  Axis.Slave  src,
  Axis.Master dest
);

logic [BITWIDTH-1:0] data_pipe [DELAY-1:0];
logic [BITWIDTH-1:0] valid_pipe [DELAY-1:0];

always_ff @(posedge clk) begin
  if (rst) begin
    src.ready  <= 'b0;
	dest.data  <= 'h0;
	dest.valid <= 'b0;
	for (int i = 0; i<DELAY; i++) begin
	  data_pipe[i] <= 'h0;
	end
  end else begin
    if (dest.ready) begin
      src.ready     <= 'b1;
      data_pipe[0]  <= src.data;
      valid_pipe[0] <= src.valid;
      for (int i = 0; i<DELAY-1; i++) begin
        data_pipe[i+1]  <= data_pipe[i];
        valid_pipe[i+1] <= valid_pipe[i];
      end
    end
  end
end

endmodule