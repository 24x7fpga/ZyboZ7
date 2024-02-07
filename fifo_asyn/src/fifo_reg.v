`include "parameters.v"

`timescale 1ns/1ns
module fifo_reg(/*AUTOARG*/
   // Outputs
   rd_data,
   // Inputs
   wr_clk, wr_en, rd_clk, rd_en, rd_empty, wr_full, rd_addr, wr_addr,
   wr_data
   );

   // outputs 
   output [`DATA_WIDTH-1:0] rd_data;
   // inputs
   input 		    wr_clk;
   input 		    wr_en;
   input 		    rd_clk;
   input 		    rd_en;
   input 		    rd_empty;
   input                    wr_full;
   input [`ADDR_WIDTH-1:0]  rd_addr;
   input [`ADDR_WIDTH-1:0]  wr_addr;
   input [`DATA_WIDTH-1:0]  wr_data;


   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [`DATA_WIDTH-1:0] rd_data;
   // End of automatics
   /*AUTOWIRE*/
   
   reg [`DATA_WIDTH-1:0]    fifo_mem[0:`DEPTH-1];

   // write operation
   always@(posedge wr_clk)
     begin
	if(wr_en && !wr_full)
	  fifo_mem[wr_addr] <= wr_data;
     end

   //read operation
//   assign rd_data = fifo_mem[rd_addr];
always@(posedge rd_clk)
     begin
	if(rd_en && !rd_empty)
	  rd_data <= fifo_mem[rd_addr];
     end

endmodule // fifo_reg
// Local Variables:
// verilog-library-directories:("~/Projects/fpgaProjects/ZyboZ7/fifo_asyn/*") 
// End:
   
