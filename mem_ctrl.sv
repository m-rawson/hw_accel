// bus to stream controller

module mem_ctrl #(
)(
  Axi.Master   preproc_mem,
  Axis.Master preproc_accel,
  Axi.Master  postproc_mem,
  Axis.Slave  postproc_accel
);

endmodule