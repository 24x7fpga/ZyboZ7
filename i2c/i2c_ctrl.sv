`include "package.svh"
module i2c_ctrl (/*AUTOARG*/
   // Outputs
   tx_data, rw, start, cont, rx_ack, o_data,
   // Inputs
   clk, rst_n, comp, busy, done, rx_data
   );
   // Outputs
   output [7:0]  tx_data;
   output	 rw;
   output	 start;
   output	 cont;
   output	 rx_ack;
   output [15:0] o_data;
   
   // Inputs
   input	 clk;
   input	 rst_n;
   input	 comp;
   input	 busy;
   input	 done;
   input [7:0]	 rx_data;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg		 cont;
   reg [15:0]	 o_data;
   reg		 rw;
   reg		 rx_ack;
   reg		 start;
   reg [7:0]	 tx_data;
   // End of automatics
   /*AUTOWIRE*/

   logic [6:0]	 addr;
   logic [7:0]	 cmd;
   logic [7:0]	 data;

   logic [1:0]	 cnt;
   logic [23:0]	 pwr_cnt;
   logic [15:0]	 rx_temp;
   logic	 done_del;
   logic	 done_rise;
   
   typedef enum {st_idle, st_powerup, st_config, st_start1, st_write, st_start2, st_recv, st_report} state_type;
   state_type st_reg, st_nxt;
   
   
   always_ff@(posedge clk) done_del <= done;
   assign done_rise = done_del & ~done;
   
   always_ff@(posedge clk)begin
      if(!rst_n) begin
	 st_reg  <= st_idle;
	 cnt     <= 2'h0;
	 pwr_cnt <= 24'h0;
      end else begin
	 st_reg  <= st_nxt;
	 pwr_cnt <= (st_reg == st_powerup) ? pwr_cnt + 1 : 24'h0;
	 if(st_reg == st_config || st_reg == st_write || st_reg == st_recv)begin
	    if(done_rise)
	      cnt <= cnt + 1'b1;
	    else
	      cnt <= cnt;
	 end else
	   cnt <= 2'h0;
      end // else: !if(!rst_n)
   end // always_ff@ (posedge clk)
   
   
   always_comb begin
      st_nxt = st_nxt;
      start  = 1'b0;
      rw     = 1'b0;
      cont   = 1'b0;
      rx_ack = 1'b0;
      
      case(st_reg)
	st_idle : begin
	   st_nxt = st_powerup;
	end
        // wait for 100ms	
	st_powerup : begin
	   if(pwr_cnt == `PWR_CNT)begin
	      st_nxt = st_config;
	      start  = 1'b1;
	   end else
	     st_nxt = st_powerup;
	end
	// set configuration
	st_config : begin
	     case(cnt)
	       2'h0 : begin
		  cont    = 1'b1;
		  tx_data = {`SLAVE_ADDR, 1'b0};
	       end
	       2'h1 : begin
		  cont    = 1'b1;
		  tx_data = `CONFIG_ADDR;
	       end
	       2'h2 : begin
		  tx_data = `CONFIG_DATA;
	       end
	       2'h3 : begin
	       st_nxt  = (comp) ? st_start1 : st_config;
	       end
	       default : tx_data = 8'h0;
	     endcase // case (cnt)
	end
	// start 
	st_start1 : begin
	   start = 1'b1;
	   if(busy)
	     st_nxt = st_recv;
	   else
	     st_nxt = st_write;
	end
	// write the temperature address
	st_write : begin
	   case(cnt)
	     2'h0 : begin
		cont    = 1'b1;
		tx_data = {`SLAVE_ADDR, 1'b0};
	     end
	     2'h1 : begin
		cont    = 1'b0;
		tx_data = `TEMP_ADDR;
	     end
	     2'h2 : begin
		st_nxt = (comp) ? st_start2 : st_write;
	     end
	   endcase // case: st_write
	end // case: st_write
	// start
	st_start2 : begin
	   start = 1'b1;
	   if(busy)
	     st_nxt = st_recv;
	   else
	     st_nxt = st_start2;
	end
	// read from temperature pointer
	st_recv : begin
	   rw     = 1'b1;
	   case(cnt)
	     2'h0 : begin
		cont = 1'b1;
		start  = 1'b1;
		tx_data = {`SLAVE_ADDR, 1'b1};
	     end
	     2'h1 : begin
		cont    = 1'b1;
		rx_ack  = 1'b0;
		rx_temp[15:8] = rx_data;
	     end
	     2'h2 : begin
		cont    = 1'b0;
		rx_ack  = 1'b1;
		rx_temp[7:0] = rx_data;
	     end
	     2'h3 : begin
		st_nxt = (comp) ? st_report : st_recv;
	     end
	   endcase // case (cnt)
	end // case: st_recv

	st_report : begin
	   st_nxt = st_recv;
	end
endcase
      end // always_comb

   always_ff@(posedge clk) o_data <= (st_reg == st_report) ? rx_temp : o_data;

endmodule // i2c_ctrl
// Local Variables:
// Verilog-Library-Directories: (".")
// End:
