// accel control mem map
// provides an interface to the core control

module accel_core_mmap (
  Axi.Slave core_ctrl,
  output logic [accel_core_pkg::MMAP_WIDTH-1:0] mmap [$bits(accel_core_pkg::MMAP_ADDR)-1:0],
  core_wr2mmap.Slave wr_mmap
);

always_ff @(posedge core_ctrl.aclk) begin
  if (!core_ctrl.aresetn) begin
  
    core_ctrl.awready <= 'b0;
    core_ctrl.aready  <= 'b0;
	core_ctrl.bvalid  <= 'b0;
	core_ctrl.bresp   <= 'b0;
	core_ctrl.arready <= 'b0;
	core_ctrl.rdata   <= 'b0;
	core_ctrl.rvalid  <= 'b0;
	
	mmap <= '{'h0};
	
  end else begin
    
    // always ready for wr addr, rd addr, & wr data
    core_ctrl.awready <= 'b1;
    core_ctrl.aready  <= 'b1;
	core_ctrl.arready <= 'b1;
	
	// Read is valid iff I am ready for addr, addr is valid, and master ready for data
    if(core_ctrl.araddr < $bits(accel_core_pkg::MMAP_ADDR)) begin
      core_ctrl.rdata  <= mmap[accel_core_pkg::MMAP_ADDR'{core_ctrl.araddr}];
      core_ctrl.rvalid <= core_ctrl.arready && core_ctrl.arvalid && core_ctrl.rready;
    end
	
	// Write is valid iff I am ready to rx data, data is valid, addr is valid
	if(core_ctrl.wready && core_ctrl.awvalid && core_ctrl.wvalid) begin
      if(core_ctrl.awaddr < accel_core_pkg::RD_ONLY) begin
	    mmap[accel_core_pkg::MMAP_ADDR'{core_ctrl.awaddr}] <= core_ctrl.wdata;
        core_ctrl.bresp   <= 'b0; // okay signal
	  end else begin 
        core_ctrl.bresp   <= 'b1; // out of range signal	    
	  end
	  core_ctrl.bvalid <= 'b1;
	end else begin
	  core_ctrl.bvalid <= 'b0;
	end
	
	// write from core
    mmap[accel_core_pkg::INPUT_BUFF_FULL]   <= wr_mmap.input_buff_full;
    mmap[accel_core_pkg::INPUT_BUFF_EMPTY]  <= wr_mmap.input_buff_empty;
    mmap[accel_core_pkg::OUTPUT_BUFF_FULL]  <= wr_mmap.output_buff_full;
    mmap[accel_core_pkg::OUTPUT_BUFF_EMPTY] <= wr_mmap.output_buff_empty;

	
  end
end



endmodule