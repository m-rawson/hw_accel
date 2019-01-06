package accel_core_pkg;

  // core mem map definition 
  localparam int MMAP_DEPTH = 'h8;

  typedef enum {
    MMAP_START_ACCEL,
    MMAP_PREPROC_START_ADDR,
    MMAP_PREPROC_END_ADDR,
    MMAP_POSTPROC_START_ADDR,
    MMAP_POSTPROC_END_ADDR
  } MMAP_T;
  
endpackage