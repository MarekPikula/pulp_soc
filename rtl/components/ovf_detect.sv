// Copyright 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module ovf_detect
(
  input logic clk_i,
  input logic rst_ni,
  input logic [31:0] pres_counter_i,
  output logic ovfwdt_o  
);


  //
  logic [31:0] past_counter; 
  logic [31:0] past2_counter;
  logic ovfwdt_int;

  always_ff @(posedge clk_i or negedge rst_ni) 
  begin
    if (~rst_ni) begin
        past_counter  <= 32'b1;
    end else begin
        past_counter  <= pres_counter_i;
        past2_counter <= past_counter;
    end
  end


  always_comb
  begin
    //todo... it is to big
    if ( (past2_counter==32'hFFFF_FFFF && past_counter ==32'h0000_0000 ) || (past_counter==32'hFFFF_FFFF && pres_counter_i ==32'h0000_0000) )
    begin
      ovfwdt_int = 1'b1;
    end
    else
    begin
      ovfwdt_int = 1'b0;
    end
  end

  assign ovfwdt_o = ovfwdt_int;
endmodule
