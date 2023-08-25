`timescale 1ns / 1ps

module data_stream_multiplexer
  #(
    parameter symbol_clk_f = 1_000_000,
    parameter clk_f = 100_000_000,
    parameter ds_width = 8
  )
  (
    input clk,
    input rst,
    input symbol_clk,
  	input [$clog2(clk_f/symbol_clk_f)-1:0] switch_clk_cycles,
    input [ds_width-1:0] ds1,
    input [ds_width-1:0] ds2,
    input [ds_width-1:0] ds3,
    input [1:0] mode,
    output [ds_width-1:0] multiplexed_data
  );
  
  localparam switch_cnt_2 = clk_f/symbol_clk_f/2;
  localparam switch_cnt_3 = clk_f/symbol_clk_f/3;
  localparam switch_cnt_d3 = 2*clk_f/symbol_clk_f/3;
  
  logic [$clog2(clk_f/symbol_clk_f)-1:0] switch_cnt_p = 'd0;
  logic [$clog2(clk_f/symbol_clk_f)-1:0] switch_cnt_n;

  
  logic [ds_width-1:0] multiplexed_data_t = 'd0;

    
  logic symbol_clk_prev = 1'b0;

  logic flag = 1'b0;
  always @(negedge clk, negedge rst) begin
    if (rst == 1'b0) begin
        flag = 1'b0;
        switch_cnt_p <= 'd0;
    end
    else begin
        if (symbol_clk == 1'b1) 
            flag <= 1'b1;
            switch_cnt_p <= 'd0;
     
        if (flag == 1'b1) begin
            if (switch_cnt_n == clk_f/symbol_clk_f) begin
                switch_cnt_p <= 'd0;
            end
            else
                switch_cnt_p <= switch_cnt_n;
        end
    end
  end
  
  assign switch_cnt_n = (rst == 1'b0) ? 'd0 : switch_cnt_p + 1'b1;
  
  always @(*) begin
    case (mode)
        2'd1: begin
            multiplexed_data_t = ds1;
        end
        
        2'd2: begin
            if(switch_cnt_p >= 0 && switch_cnt_p < switch_cnt_2)
                multiplexed_data_t = ds1;
            else
                multiplexed_data_t = ds2;
        end
        2'd3: begin
            if(switch_cnt_p >= 0 && switch_cnt_p < switch_cnt_3)
                multiplexed_data_t = ds1;
            else if (switch_cnt_p >= switch_cnt_3 && switch_cnt_p < switch_cnt_d3)
                multiplexed_data_t = ds2;
            else
                multiplexed_data_t = ds3;
        end
        default:
            multiplexed_data_t = 'd0;
    endcase
  end
  
  assign multiplexed_data = multiplexed_data_t;
endmodule