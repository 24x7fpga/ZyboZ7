`include "package.svh"
module zybo_z7_top (/*AUTOARG*/
   // Outputs
   led,
   // Inouts
   sda, scl,
   // Inputs
   clk, rst, sw
   );
   // Outputs
   inout tri1           sda;
   inout tri1           scl;
   output [3:0]	        led;
   // Inputs
   input        	clk;
   input	        rst;
   input [3:0]  	sw;

   logic        	rst_n;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [3:0]		led;
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			busy;			// From MSTR of i2c_master.v
   wire			comp;			// From MSTR of i2c_master.v
   wire			cont;			// From CTRL of i2c_ctrl.v
   wire			done;			// From MSTR of i2c_master.v
   wire [15:0]		o_data;			// From CTRL of i2c_ctrl.v
   wire			o_scl;			// From MSTR of i2c_master.v
   wire			o_sda;			// From MSTR of i2c_master.v
   wire			rw;			// From CTRL of i2c_ctrl.v
   wire			rx_ack;			// From CTRL of i2c_ctrl.v
   wire [7:0]		rx_data;		// From MSTR of i2c_master.v
   wire			start;			// From CTRL of i2c_ctrl.v
   wire [7:0]		tx_data;		// From CTRL of i2c_ctrl.v
   // End of automatics

   assign rst_n = ~rst;

   i2c_ctrl CTRL (/*AUTOINST*/
		  // Outputs
		  .tx_data		(tx_data[7:0]),
		  .rw			(rw),
		  .start		(start),
		  .cont			(cont),
		  .rx_ack		(rx_ack),
		  .o_data		(o_data[15:0]),
		  // Inputs
		  .clk			(clk),
		  .rst_n		(rst_n),
		  .comp			(comp),
		  .busy			(busy),
		  .done			(done),
		  .rx_data		(rx_data[7:0]));

   i2c_master MSTR (/*AUTOINST*/
		    // Outputs
		    .o_sda		(o_sda),
		    .o_scl		(o_scl),
		    .busy		(busy),
		    .done		(done),
		    .comp		(comp),
		    .rx_data		(rx_data[7:0]),
		    // Inputs
		    .clk		(clk),
		    .rst_n		(rst_n),
		    .rw			(rw),
		    .cont		(cont),
		    .start		(start),
		    .i_sda		(i_sda),
		    .rx_ack		(rx_ack),
		    .tx_data		(tx_data[7:0]));

  
   always_comb begin
      casez(sw)
	4'b1??? : led = o_data[15:12];
	4'b01?? : led = o_data[11:8];
	4'b001? : led = o_data[7:4];
	4'b0001 : led = o_data[3:0];
	default : led = 4'hF;
      endcase // casez (sw)
   end
   
// IOBUF: Single-ended Bi-directional Buffer
//        All devices
// Xilinx HDL Libraries Guide, version 13.4
IOBUF  IOBUF_SDA (
    .O(i_sda),      // Buffer output
    .IO(sda),    // Buffer inout port (connect directly to top-level port)
    .I(o_sda),      // Buffer input
    .T(o_sda)       // 3-state enable input, high=input, low=output
);  // End of IOBUF_inst instantiation

// IOBUF: Single-ended Bi-directional Buffer
//        All devices
// Xilinx HDL Libraries Guide, version 13.4
IOBUF IOBUF_SCL (
    .O(in_scl),      // Buffer output
    .IO(scl),    // Buffer inout port (connect directly to top-level port)
    .I(o_scl),      // Buffer input
    .T(o_scl)       // 3-state enable input, high=input, low=output
);  // End of IOBUF_inst instantiation

endmodule // zybo_z7_top
// Local Variables:
// Verilog-Library-Directories: (".")
// End:

	
