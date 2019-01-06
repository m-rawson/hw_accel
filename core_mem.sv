// handles partitioning, and arbitration

module core_mem #(
  parameter int MEM_ADDR_WIDTH=16
)(
  // ctrl clk
  input wire ctrl_clk,
  input wire ctrl_rst,
  input [accel_core_pkg::MMAP_WIDTH-1:0] mmap [$bits(accel_core_pkg::MMAP_ADDR)-1:0],
  // mem clk
  Axi.Slave user_mem_bus,
  Axi.Slave accel_mem_bus
);

// data from mmap
logic [accel_core_pkg::MMAP_WIDTH-1:0] preproc_start_addr, preproc_end_addr;
logic [accel_core_pkg::MMAP_WIDTH-1:0] postproc_start_addr, postproc_end_addr;
logic start_accel;

// master port into actual mem 
logic aresetn;
Axi #(
  .WDATA_WIDTH(MEM_ADDR_WIDTH), .RDATA_WIDTH(MEM_ADDR_WIDTH)
) mem_port(
  .aclk(user_mem_bus.aclk), 
  .aresetn
);

// calculating the accel physical address
// postproc is write only
logic [MEM_ADDR_WIDTH-1:0] accel_phy_waddr = accel_mem_bus.awaddr + postproc_start_addr;
logic accel_phy_wvalid = accel_mem_bus.awvalid && (accel_phy_waddr < postproc_end_addr);
// preproc is read only
logic [MEM_ADDR_WIDTH-1:0] accel_phy_raddr = accel_mem_bus.araddr + preproc_start_addr;
logic accel_phy_rvalid = accel_mem_bus.arvalid && (accel_phy_raddr < preproc_end_addr);

always_ff @(posedge user_mem_bus.aclk) begin
  if(~start_accel) begin
    // if not processing, user has full w/r to mem and accel stalled
    aresetn              <= user_mem_bus.aresetn;
    // wr addr
    mem_port.awaddr      <= user_mem_bus.awaddr;
    mem_port.awvalid     <= user_mem_bus.awvalid;
    user_mem_bus.awready <= mem_port.awready;
    // wr data
    mem_port.wdata       <= user_mem_bus.wdata;
    mem_port.wvalid      <= user_mem_bus.wvalid;
    user_mem_bus.wready  <= mem_port.wready;
    // wr response
    user_mem_bus.bvalid  <= mem_port.bvalid;
    user_mem_bus.bresp   <= mem_port.bresp;
    mem_port.bready      <= user_mem_bus.bready;
    // rd addr
    mem_port.araddr      <= user_mem_bus.araddr;
    mem_port.arvalid     <= user_mem_bus.arvalid;
    user_mem_bus.arready <= mem_port.arready;
    // rd data
    user_mem_bus.rdata   <= mem_port.rdata;
    user_mem_bus.rvalid  <= mem_port.rvalid;
    mem_port.rready      <= user_mem_bus.rready;
    
    // stalling the accel bus
    // wr addr
    accel_mem_bus.awready <= 'b0;
    // wr data
    accel_mem_bus.wready  <= 'b0;
    // wr response
    accel_mem_bus.bvalid  <= 'b0;
    accel_mem_bus.bresp   <= 'b0;
    // rd addr
    accel_mem_bus.arready <= 'b0;
    // rd data
    accel_mem_bus.rdata   <= 'h0;
    accel_mem_bus.rvalid  <= 'b0;
    
  end else begin
    // if processing, accel has full w/r to mem and user stalled
    aresetn               <= accel_mem_bus.aresetn;
    // wr addr
    mem_port.awaddr       <= accel_phy_waddr;
    mem_port.awvalid      <= accel_phy_wvalid;
    accel_mem_bus.awready <= mem_port.awready;
    // wr data
    mem_port.wdata        <= accel_mem_bus.wdata;
    mem_port.wvalid       <= accel_mem_bus.wvalid;
    accel_mem_bus.wready  <= mem_port.wready;
    // wr response
    accel_mem_bus.bvalid  <= mem_port.bvalid;
    accel_mem_bus.bresp   <= mem_port.bresp;
    mem_port.bready       <= accel_mem_bus.bready;
    // rd addr
    mem_port.araddr       <= accel_phy_raddr;
    mem_port.arvalid      <= accel_phy_rvalid;
    accel_mem_bus.arready <= mem_port.arready;
    // rd data
    accel_mem_bus.rdata   <= mem_port.rdata;
    accel_mem_bus.rvalid  <= mem_port.rvalid;
    mem_port.rready       <= accel_mem_bus.rready;
    
    // stalling the user bus
    // wr addr
    user_mem_bus.awready <= 'b0;
    // wr data
    user_mem_bus.wready  <= 'b0;
    // wr response
    user_mem_bus.bvalid  <= 'b0;
    user_mem_bus.bresp   <= 'b0;
    // rd addr
    user_mem_bus.arready <= 'b0;
    // rd data
    user_mem_bus.rdata   <= 'h0;
    user_mem_bus.rvalid  <= 'b0;
    
  end
end


// get memory partitions from the mmap (low throughput, using handshake)
// just going to get all the signals at once
Axis #(logic[(4*accel_core_pkg::MMAP_WIDTH)-1:0]) wr_stream ();
assign wr_stream.data = {
  mmap[accel_core_pkg::PREPROC_START_ADDR],
  mmap[accel_core_pkg::PREPROC_END_ADDR],
  mmap[accel_core_pkg::POSTPROC_START_ADDR],
  mmap[accel_core_pkg::POSTPROC_END_ADDR]
};
assign wr_stream.valid = 'b1; // Only not true w/rst
Axis #(logic[(4*accel_core_pkg::MMAP_WIDTH)-1:0]) rd_stream ();
assign rd_stream.ready = 'b1; // Only not true w/rst

handshake #(
  .BITWIDTH(4*accel_core_pkg::MMAP_WIDTH)
) partition_sync_i (
  .wr_clk(ctrl_clk),
  .wr_rst(ctrl_rst),
  .rd_clk(mem_bus.aclk),
  .rd_rst(~mem_bus.aresetn),
  .wr_stream,
  .rd_stream
);

assign {
  preproc_start_addr, 
  preproc_end_addr, 
  postproc_start_addr, 
  postproc_end_addr} = rd_stream.data;

// mf_sync the start accel bit
multiflop_sync #(
  .BITWIDTH(1),
  .SYNC_STAGES(4)
) start_sync_i (
  src_clk(ctrl_clk),
  src_rst(ctrl_rst),
  src(mmap[accel_core_pkg::START_ACCEL][0]),
  dest_clk(mem_bus.aclk),
  dest_rst(~mem_bus.aresetn),
  dest(start_accel)
);

endmodule