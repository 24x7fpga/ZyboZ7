`timescale 1ns/1ns 
module zybo_z7_top (/*AUTOARG*/
   // Outputs
   tx, led,
   // Inputs
   clk, rst, rx, sw, btn
   ); 
   // Outputs
   output       tx;
   output [3:0]	led;
   // Inputs
   input	clk;
   input	rst;
   input	rx;
   input	sw;
   input	btn;

   localparam	DBIT = 8;
   localparam	SB_TICK = 16;
   
   logic [7:0]	din = 8'h41;
   logic [10:0]	dvsr = 11'd66;
   
  /*AUTOREG*/ 
  /*AUTOWIRE*/ 
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [DBIT-1:0]	dout;			// From TOP of uart.v
  logic			rx_done_tick;		// From TOP of uart.v
  logic			tx_done_tick;		// From TOP of uart.v
  // End of automatics

   logic tx_start;
   
   // debouncing logic
   logic [21:0] delay = 22'd3750000; //30ms
   logic [21:0] d_cnt;
   
   always_ff@(posedge clk)begin
       if(rst)begin
        d_cnt   <= 22'h0;
       end else begin
        if(st_reg == st_start)
            d_cnt <= d_cnt + 1;
        else
            d_cnt <= 22'h0;
       end       
   end 
   
   typedef enum {st_idle, st_start, st_debounce, st_end} state_type;
   state_type st_reg, st_nxt;
   
   always_ff@(posedge clk)begin
      if(rst)
	st_reg <= st_idle;
      else
	st_reg <= st_nxt;
   end
   
   always_comb begin
      st_nxt = st_reg;
      tx_start = 1'b0;
      case(st_reg)
	st_idle : begin
	   if(btn)
	     st_nxt = st_start;
	   else
	     st_nxt = st_idle;
	end
	
	st_start : begin
	   // wait till 30ms
	   if(d_cnt == delay-1)
	     st_nxt = st_debounce;
	   else 
	     st_nxt = st_start;
	end 
	
	st_debounce : begin
	   // stable input
	   if(btn)begin
	      st_nxt = st_end;
	      tx_start = 1'b1;    
	   end else 
	     st_nxt = st_idle;
	end
	
	st_end : begin
	   if(~btn)
	     st_nxt = st_idle;
	   else
	     st_nxt = st_end;
	end
      endcase
   end
   
   uart #(/*AUTOINSTPARAM*/
	  // Parameters
	  .DBIT				(DBIT),
	  .SB_TICK			(SB_TICK)) TOP (/*AUTOINST*/
							// Outputs
							.tx		(tx),
							.tx_done_tick	(tx_done_tick),
							.rx_done_tick	(rx_done_tick),
							.dout		(dout[DBIT-1:0]),
							// Inputs
							.clk		(clk),
							.rst		(rst),
							.din		(din[DBIT-1:0]),
							.dvsr		(dvsr[10:0]),
							.tx_start	(tx_start),
							.rx		(rx));
   
   assign led = sw ? dout[7:4] : dout[3:0];
 
endmodule 
// Local Variables: 
// Verilog-Library-Directories: (".")
// End:
