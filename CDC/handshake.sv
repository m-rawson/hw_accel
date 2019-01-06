// handshake

module handshake #(
  parameter int BITWIDTH=1
)(
  input  wire wr_clk,
  input  wire rd_clk,
  input  wire rst,
  Axis.Slave  wr_stream,
  Axis.Master rd_stream
);

localparam int DELAY_LINE=2;

// rd clk domain
logic [BITWIDTH-1:0] buff [DELAY_LINE-1:0];
logic [BITWIDTH-1:0] feed;

// assigned on wr_clk, read on rd_clk
logic [BITWIDTH-1:0] hold;
logic src_send, src_send_sync;

// assigned on rd_clk, read on wr_clk
logic dest_rcv, dest_rcv_sync;

// ready to write when dest rcv the data
assign wr_stream.ready = dest_rcv_sync;

// fsm signals
typedef enum {
  IDLE,
  CDC,
  VALID,
  SHAKE,
  FILLING_BUFF
} State_t;
State_t rd_state, next_rd_state;
State_t wr_state, next_wr_state;


// wr state
always_ff @(posedge wr_clk) begin
  if(rst) begin
    wr_state <= IDLE;
    hold <= 'h0;
  end else begin
    wr_state <= next_wr_state;
	if(wr_stream.ok) begin
      hold <= wr_stream.data;
	end
  end
end

// wr next state logic
always_comb begin
  // defaults
  wr_stream.ready = 'h0;
  src_send = 'h0;
  
  case(wr_state)
    IDLE: begin
	  // waiting for send req
	  next_wr_state = (wr_stream.ok) ? CDC : IDLE;
      wr_stream.ready = 'h1;
	end
	CDC: begin
	  // hold is valid, send goes high
	  // held high until data successfully crosses
	  next_wr_state = (dest_rcv_sync) ? VALID : CDC;
	  src_send = 'h1;
	end
	VALID: begin
	  // send goes low until rcv signal goes back low
	  next_wr_state = (~dest_rcv_sync) ? IDLE : IDLE;
	  src_send = 'h0;	  
    end
  endcase
end

// multiflop synchronizer for src send
sync_single send_sync_i (
  .rst,
  .src(src_send),
  .dest_clk(rd_clk),
  .dest(src_send_sync)
);

// rd next state and output logic
always_comb begin
  //defaults
  next_rd_state = rd_state;
  feed = 'h0;
  rd_stream.valid = 'h0;
  rd_stream.data = 'h0;
  dest_rcv = 'h0;
  // FSM
  case (rd_state)
    IDLE: begin
	  // waiting for hold to be valid
      next_rd_state = (src_send_sync) ? FILLING_BUFF : IDLE;
    end
	FILLING_BUFF: begin
	  // push hold to buffer
	  // wait for buffer to fill and all be equal
	  feed = hold;
      next_rd_state = (~(buff[1] - buff[0])) ? VALID : FILLING_BUFF;
	end
	VALID: begin
	  // buffer data is valid in rd clk domain
	  // wait for ready to go true so value gets read
	  next_rd_state = (rd_stream.ok) ? IDLE : VALID;
      rd_stream.valid = ~(^(buff[DELAY_LINE-1:0]));
      rd_stream.data = buff[DELAY_LINE-1];
    end
	SHAKE: begin
	  // now data has been read output
	  // signal wr domain 
	  // wait for wr domain to show it received rcv signal by dropping send back to 0
	  next_rd_state = (~src_send_sync) ? IDLE : SHAKE;
	  dest_rcv = 'h1;
	end
  endcase
end

// multiflop synchronizer for rcv send
sync_single rcv_sync_i (
  .rst,
  .src(dest_rcv),
  .dest_clk(wr_clk),
  .dest(dest_rcv_sync)
);

// buffer and rd state
always_ff @(posedge rd_clk) begin
  if (rst) begin
    rd_state <= IDLE;
    for(int i=0; i<DELAY_LINE; i++) begin
	  buff[i] <= i;
	end
  end else begin
    rd_state <= next_rd_state;
    buff[0] <= feed;
    for(int i=0; i<DELAY_LINE-1; i++) begin
	  buff[i+1] <= buff[i];
    end
  end
end

endmodule