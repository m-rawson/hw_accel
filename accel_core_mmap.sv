// accel control mem map
// provides an interface to the core control

module accel_core_mmap (
  Axi.Slave core_ctrl,
  output accel_core_pkg::MMAP_T mmap [accel_core_pkg::MMAP_DEPTH-1:0]
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
	
  end else begin
  
    core_ctrl.awready <= 'b1;
    core_ctrl.aready  <= 'b1;
	core_ctrl.arready <= 'b1;
	
	// Read is valid iff I am ready for addr, addr is valid, and master ready for data
    if(core_ctrl.araddr < accel_core_pkg::MMAP_DEPTH) begin
      core_ctrl.rdata  <= mmap[accel_core_pkg::MMAP_T'{core_ctrl.araddr}];
      core_ctrl.rvalid <= core_ctrl.arready && core_ctrl.arvalid && core_ctrl.rready;
    end
	
	// Write is valid iff I am ready to rx data, data is valid, addr is valid
	if(core_ctrl.wready && core_ctrl.awvalid && core_ctrl.wvalid) begin
      if(core_ctrl.awaddr < accel_core_pkg::MMAP_DEPTH) begin
	    mmap[accel_core_pkg::MMAP_T'{core_ctrl.awaddr}] <= core_ctrl.wdata;
        core_ctrl.bresp   <= 'b0; // okay signal
	  end else begin 
        core_ctrl.bresp   <= 'b1; // out of range signal	    
	  end
	  core_ctrl.bvalid <= 'b1;
	end else begin
	  core_ctrl.bvalid <= 'b0;
	end
	
  end
end

endmodule