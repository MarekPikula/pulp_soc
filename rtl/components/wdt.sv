// Copyright 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define CONFIG_WDT         4'h0
`define INIT_VALUE         4'h4
`define COUNTER_VALUE      4'h8

`define ENABLE_BIT         'd0
`define CLEAR_BIT          'd1
`define CLK_SELECT_BIT     'd2
`define SCALER_BIT         'd3


module wdt
#(
  parameter APB_ADDR_WIDTH = 12
)
(
  input logic clk1_i,
  input logic clk2_i,
  input logic rst_ni,

  output logic reset_wdt,

  //apb
  input  logic                      HCLK,
  input  logic                      HRESETn,
  input  logic [APB_ADDR_WIDTH-1:0] PADDR,
  input  logic               [31:0] PWDATA,
  input  logic                      PWRITE,
  input  logic                      PSEL,
  input  logic                      PENABLE,
  output logic               [31:0] PRDATA,
  output logic                      PREADY,
  output logic                      PSLVERR

);


  logic clk;
  logic reset;
  logic [31:0] init_value;
  logic enable;
  logic clear;
  logic [31:0] outv;
  logic out_ovf;

  assign reset = rst_ni;

  //TODO
  assign clk = clk1_i;

  //SCALER: TODO
  //
 

  //counter:
  counter_wdt i_counter_wdt (
    .clk_i           ( clk        ),

    .rst_ni          ( reset      ),
    .init_value_i    ( init_value ),
    .enable_i        ( enable     ),
    .clear_i         ( clear      ),
    .counter_value_o ( outv       )
  );

  //overflow detect:
  ovf_detect i_ovf_detect (
    .clk_i           ( clk        ),
    .rst_ni          ( reset      ),
    .pres_counter_i  ( outv       ),
    .ovfwdt_o        ( out_ovf    )
  );  


  assign reset_wdt = out_ovf;

  logic s_apb_write;
  logic [3:0] s_apb_addr;
  logic [31:0] reg_config;
  logic [31:0] reg_init_value;
  logic [31:0] reg_counter;

  assign s_apb_write = PSEL && PENABLE && PWRITE;

  assign s_apb_addr  = PADDR[3:0];

  //reg counter 
  assign reg_counter = outv;

  //init value:
  assign init_value  = reg_init_value;

  assign enable      = reg_config[`ENABLE_BIT];
  assign clear       = reg_config[`CLEAR_BIT];

  //todo:
//  assign clk_select
//  assign scaler_bit

  always_ff @(posedge HCLK, negedge HRESETn) begin
    if(~HRESETn) begin
      reg_config[`CLEAR_BIT] <= 1'b0;
    end else if (reg_config[`CLEAR_BIT]) begin
      reg_config[`CLEAR_BIT] <= 1'b0;
    end
  end

  //write logic:
  always_ff @(posedge HCLK, negedge HRESETn) begin
    if(~HRESETn) begin
      reg_config         <= 32'b0; // <-- wdt disable, clear = 0; clk_select =0; scaler = 0;
      reg_init_value     <= 32'h0000_0001;
    end else begin      
      if (s_apb_write) begin
        if (s_apb_addr == `CONFIG_WDT) begin
          reg_config     <= PWDATA;
        end else if (s_apb_addr == `INIT_VALUE) begin
          reg_init_value <= PWDATA;
        end
      end
    end
  end

  //read logic
  always_comb begin
    PRDATA = '0;
    case (s_apb_addr)
      `CONFIG_WDT   : PRDATA = reg_config;
      `INIT_VALUE   : PRDATA = reg_init_value;
      `COUNTER_VALUE: PRDATA = reg_counter;
      default       : PRDATA = 32'b0;
    endcase
  end

  assign PREADY     = 1'b1;
  assign PSLVERR    = 1'b0;

endmodule