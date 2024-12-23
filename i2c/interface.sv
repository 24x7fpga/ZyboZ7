`include "package.svh"
interface i2c_intf (input m_clk);
   // clk
   logic       clk;
   // reset
   logic       rst;

   wire	       scl, sda;

   wire [3:0]  led; 
   reg [3:0]   sw;
   
   // simulation signals
   logic       dir, wr_dir, rd_dir;
   logic       sda_out;
   logic       wr_sda, rd_sda;
   
   logic       sda_del, sda_fall, sda_rise;
   logic       done, wr_check, send, rd_done;
   
   logic       start = 1'b0;
   logic [3:0] cnt_reg, cnt;
   logic [7:0] data; 
   logic [5:0] rd_cnt;
   
   logic [17:0]	tx_data;
   logic [15:0]	rx_data;
   
   logic [15:0]	send_data = 16'h1234;
   
   assign tx_data = {send_data[15:8], 1'bz, send_data[7:0], 1'bz};

   assign clk = m_clk;
   assign dir = wr_dir || rd_dir;
   
    // sda  edge detection
    always_ff@(posedge clk) sda_del <= sda;
    // sda fall edge
    assign sda_fall = sda_del & ~sda;
    // sda rise edge
    assign sda_rise = ~sda_del & sda;

   // start and stop detection 
   always_ff@(posedge clk)begin
    if(scl & sda_fall)
        start <= 1'b1;
    else if(scl & sda_rise)
        start <= 1'b0;
    else
        start <= start;
    end
   
   // reset
   task reset();
      rst <= 1'b1;
      wr_dir <= 1'b0;
      rd_dir <= 1'b0;
      send   <= 1'b0;
      repeat (5) @(posedge clk);
      rst <= 1'b0;
      repeat (`DVSR) @(posedge clk);
   endtask // reset

   // write
   task run();
      wr_dir <= 1'b0;
      rd_dir <= 1'b0;
      
      cnt <= 4'h0;
      // slave address
      wait(done);
      wr_dir <= 1'b1;
      wait(!done);
      wr_dir <=1'b0;
      // config pointer
      wait(done);
      wr_dir <= 1'b1;
      wait(!done);
      wr_dir <=1'b0;
      // config data
      wait(done);
      wr_dir <= 1'b1;
      wait(!done);
      wr_dir <=1'b0;
      // slave address
      wait(done);
      wr_dir <= 1'b1;
      wait(!done);
      wr_dir <=1'b0;
      // temp address
      wait(done);
      wr_dir <= 1'b1;
      wait(!done);
      wr_dir <=1'b0;
      // slave address
      wait(done);
      wr_dir <= 1'b1;
      wait(!done);
      wr_dir <=1'b0;
      // read data
      rd_dir <= 1'b1;
      send   <= 1'b1;   
      wait(rd_done);
      send   <= 1'b0;
      // collect data
      wait(scl & sda);
      repeat (`DVSR) @(posedge clk);
      @(posedge clk)
      sw <= 4'h8;
      @(posedge clk)
      rx_data[15:12] <= led;
      
      @(posedge clk)
      sw <= 4'h4;
      @(posedge clk)
      rx_data[11:8] <= led;
      
      @(posedge clk)
      sw <= 4'h2;
      @(posedge clk)
      rx_data[7:4] <= led;
      
      @(posedge clk)
      sw <= 4'h1;
      @(posedge clk)
      rx_data[3:0] <= led;
      
      @(posedge clk)
      if(rx_data == send_data)
      $display("PASS ;) :: REC DATA = %h", rx_data);
      else
      $error("PASS ;) :: REC DATA = %h", rx_data);
 
      repeat (`DVSR) @(posedge clk);
   endtask // run

    
    // write verification
    assign wr_check = (data[7:1] == `SLAVE_ADDR) || (data == `CONFIG_ADDR) || (data == `CONFIG_DATA) || (data == `TEMP_ADDR);
    
    always_ff@(posedge scl, negedge start)begin
        if(!start)
            cnt <= 4'h0;
        else begin
        if(cnt == 8)begin
            done <=1 ;
            if(wr_check)begin
            wr_sda  <= 0;
            cnt     <= 0;
            $display("PASS ;) :: SDA DATA = %h", data);
            end else begin
            wr_sda  <= 1;
            cnt     <= 0;
            $display("FAIL :( :: SDA DATA = %h", data);
            end
         end else begin     
            done <= 0;
            data <= {data[6:0], sda};
            cnt  <= cnt + 1;
         end
       end
   end
   
   // read transfer
   always_ff@(posedge scl)begin
    if(send)begin  
        if(rd_cnt == 0)begin
            rd_done <= 1;
            rd_cnt  <= 5'h0;
        end else begin
            rd_done <= 0;
            rd_cnt  <= rd_cnt - 1;
        end
    end else
        rd_cnt  <= 5'd17;
    end
    
    assign rd_sda  = tx_data[rd_cnt];
    assign sda_out = (wr_dir) ? wr_sda : (rd_dir) ? rd_sda : 1'bz; 
   
endinterface // i2c_intf
// Local Variables:
// Verilog-Library-Directories: (".")
// End:
