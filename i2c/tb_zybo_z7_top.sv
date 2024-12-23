`include "package.svh"
module tb_zybo_z7_top ();
   // CLock
   logic m_clk;

   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [3:0]		led;			// From DUT of zybo_z7_top.v
   tri1			scl;			// To/From DUT of zybo_z7_top.v
   tri1			sda;			// To/From DUT of zybo_z7_top.v
   // End of automatics

   // interface
   i2c_intf intf (m_clk);

   // dut
   zybo_z7_top DUT (
		    // Outputs
		    .led		(intf.led[3:0]),
		    // Inouts
		    .sda		(intf.sda),
		    .scl		(intf.scl),
		    // Inputs
		    .clk		(intf.clk),
		    .rst		(intf.rst),
		    .sw			(intf.sw[3:0]));

   // generate clk
   always #(`T/2) m_clk = (m_clk === 1'b0);

   // model pullup registers
   pullup (intf.sda);
   assign intf.sda = intf.dir ? intf.sda_out : 1'bz;
   pullup (intf.scl);
   assign intf.scl = 1'bz;

   initial begin
      intf.reset();
      intf.run();
      $finish;
   end

endmodule // tb_zybo_z7_top
// Local Variables:
// Verilog-Library-Directories: (".")
// End:
