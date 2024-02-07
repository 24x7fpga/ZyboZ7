`include "parameters.v"

`timescale 1ns / 1ps

module top_module(/*AUTOARG*/
   // Outputs
   rd_data, wr_full, rd_empty,
   // Inputs
   clk_in1, wr_en, wr_rst, rd_en, rd_rst, wr_data
   );
    
   // outputs
   output [`DATA_WIDTH-1:0] rd_data;
   output 		    wr_full;
   output 		    rd_empty;
   // inputs
   input 		    clk_in1;
   input 		    wr_en, wr_rst;
   input 		    rd_en, rd_rst;
   input [`DATA_WIDTH-1:0]  wr_data;
    
    
   clk_wiz_0 CLK_WIZ (/*AUTOINST*/
			      // Outputs
			      .wr_clk_out		(wr_clk),
			      .rd_clk_out		(rd_clk),
			      // Inputs
			      .clk_in1		(clk_in1));

   fifo_asyn FIFO_MOD (/*AUTOINST*/
		       // Outputs
		       .rd_data		(rd_data[`DATA_WIDTH-1:0]),
		       .wr_full		(wr_full),
		       .rd_empty	(rd_empty),
		       // Inputs
		       .wr_clk		(wr_clk),
		       .wr_en		(wr_en),
		       .wr_rst		(wr_rst),
		       .rd_clk		(rd_clk),
		       .rd_en		(rd_en),
		       .rd_rst		(rd_rst),
		       .wr_data		(wr_data[`DATA_WIDTH-1:0]));
   
endmodule
// Local Variables:
// verilog-library-directories:("~/Projects/fpgaProjects/ZyboZ7/fifo_asyn/*") 
// End:
