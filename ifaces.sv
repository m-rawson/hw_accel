// Interfaces

interface Mem
#( 
)(
);

modport Master ();

modport Slave ();

endinterface

// Axi lite interface
interface Axi
#(
  parameter int WDATA_WIDTH = 32,
  parameter int RDATA_WIDTH = 32 
)();

// Bus
wire aclk;
wire aresetn;

// Wire Address
wire [31:0] awaddr;
wire [3:0]  awcache = 'b0011;
wire [2:0]  awprot = 'b000;
wire awvalid;
wire awready;

// Wire Data
wire [WDATA_WIDTH-1:0] wdata;
wire wvalid;
wire wready;

// Write Response
wire bvalid;
wire bready;
wire bresp;

// Read Address
wire [31:0] araddr;
wire arcache = 'b0011;
wire arprot = 'b000;
wire arvalid;
wire arready;

// Read data
wire [RDATA_WIDTH-1:0] rdata;
wire rvalid;
wire rready;

modport Master (
// Bus
output aclk,
output aresetn,
// Wire Address
output awaddr,
output awvalid,
input  awready,
// Wire Data
output wdata,
output wvalid,
input  wready,
// Write Response
output bready,
input  bvalid,
input  bresp,
// Read Address
output araddr,
output arvalid,
input  arready,
// Read data
input  rdata,
input  rvalid,
output rready
);

modport Slave (
// Bus
input  aclk,
input  aresetn,
// Wire Address
input  awaddr,
input  awvalid,
output awready,
// Wire Data
input  wdata,
input  wvalid,
output wready,
// Write Response
output bvalid,
output bresp,
input  bready,
// Read Address
input  araddr,
input  arvalid,
output arready,
// Read data
output rdata,
output rvalid,
input  rready
);

endinterface

// Axi Stream interface
interface Axis
#(
  parameter type = logic[0:0];
)();

wire ready;
wire valid;
D_t data;
wire ok = ready	& valid;

modport Master (
  input  ready,
  output valid,
  output data
);

modport Slave (
  input  data,
  input  valid,
  output ready
);

endinterface
