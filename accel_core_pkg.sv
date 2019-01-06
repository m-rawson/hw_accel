package accel_core_pkg;

  // core mem map definition 
  localparam int MMAP_DEPTH = 'h8;

  enum typedef MMAP_ADDR_T {
    MMAP_PREPROC_START_ADDR,
    MMAP_PREPROC_END_ADDR,
    MMAP_POSTPROC_START_ADDR,
    MMAP_POSTPROC_END_ADDR,
    MMAP_START_ACCEL
  };
  
  
  
endpackage 