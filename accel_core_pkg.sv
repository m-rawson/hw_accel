package accel_core_pkg;

  // core mem map definition 
  localparam int MMAP_WIDTH = 'h8;

  // valid values for addresses
  // wr access to user
  typedef enum {
    START_ACCEL,
    PREPROC_START_ADDR,
    PREPROC_END_ADDR,
    POSTPROC_START_ADDR,
    POSTPROC_END_ADDR,
    RD_ONLY, // rd accesss only to user below this point
    INPUT_BUFF_FULL,
	INPUT_BUFF_EMPTY,
	OUTPUT_BUFF_FULL,
	OUTPUT_BUFF_EMPTY
  } MMAP_ADDR;

endpackage

interface core_wr2mmap_inf #()();
wire input_buff_full;
wire input_buff_empty;
wire output_buff_full;
wire output_buff_empty;

modport Master (
  output input_buff_full,
  output input_buff_empty,
  output output_buff_full,
  output output_buff_empty
);

modport Slave (
  input input_buff_full,
  input  input_buff_empty,
  input  output_buff_full,
  input  output_buff_empty
);
endinterface