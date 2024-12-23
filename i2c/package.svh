`ifndef PACKAGE_SVH
 `define PACKAGE_SVH

// Define Timescale
 `timescale 1ns/1ns

// Define Clock
 `define T           4'h8       // 125MHz => Zybo Z7-20
 `define DVSR       11'd1250    // 100kHz

// Slave Address
 `define SLAVE_ADDR  7'h48     // Slave Address
 `define CONFIG_ADDR 8'h01     // Temperature Register Address
 `define CONFIG_DATA 8'h00     // Config 
 `define TEMP_ADDR   8'h00     // Config Register Address

// Power up DVSR
`define PWR_CNT 24'd12500000   // 100ms
//`define PWR_CNT 24'd125000      // 1ms for simulations
`endif
