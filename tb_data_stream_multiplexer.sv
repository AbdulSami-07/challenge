`timescale 1ns / 1ps

module tb_data_stream_multiplexer;

  parameter tb_clk_f = 100_000_000; // in Hz
  parameter tb_clk_p = 10; // in ns
  
  // for 1KHz , uncomment them///
//  parameter tb_symbol_clk_f = 1_000; // in Hz
//  parameter tb_symbol_clk_p = 1_000_000; // in ns
  //////////////////////////
  
  
  /// for 1MHz, uncomment them ///
//  parameter tb_symbol_clk_f = 1_000_000; // in Hz
//  parameter tb_symbol_clk_p = 1_000; // in 
  ////////////////
  
//    /// for 50MHz, uncomment them ///
  parameter tb_symbol_clk_f = 50_000_000; // in Hz
  parameter tb_symbol_clk_p = 20; // in 
//  ////////////////
  parameter tb_ds_width = 4;

  // dut signal declaration //
  reg tb_clk;
  reg tb_rst;
  reg tb_symbol_clk;
  reg [$clog2(tb_clk_f/tb_symbol_clk_f)-1:0] tb_switch_clk_cycles;
  reg [tb_ds_width-1:0] tb_ds1;
  reg [tb_ds_width-1:0] tb_ds2;
  reg [tb_ds_width-1:0] tb_ds3;
  reg [1:0] tb_mode;
  wire [tb_ds_width-1:0] tb_multiplexed_data;
  ////////////////////////////
  
  // dut instantiation //
  data_stream_multiplexer #(
    .symbol_clk_f(tb_symbol_clk_f),
    .clk_f(tb_clk_f),
    .ds_width(tb_ds_width)
  ) dsm0 (
    .clk(tb_clk),
    .rst(tb_rst),
    .symbol_clk(tb_symbol_clk),
    .switch_clk_cycles(tb_symbol_clk),
    .ds1(tb_ds1),
    .ds2(tb_ds2),
    .ds3(tb_ds3),
    .mode(tb_mode),
    .multiplexed_data(tb_multiplexed_data)
  );
  ///////////////////////
  
  // tb_clk generator //
  	always begin
      #(tb_clk_p/2) tb_clk = ~ tb_clk;
    end
  //////////////////////
  
  // tb_symbol_clk generator //
  	always begin
      #(tb_symbol_clk_p/2);
      tb_symbol_clk = 1'b1;
      #(tb_symbol_clk_p/2);
      tb_symbol_clk = 1'b0;
//      #(tb_symbol_clk_p/2 - tb_clk_p/2);  
    end
  /////////////////////////////
      
  // data stream generator //
      always @(posedge tb_symbol_clk) begin
        tb_ds1 <= $random;
        tb_ds2 <= $random;
        tb_ds3 <= $random;
      end
  ///////////////////////////
  
  // initialize the signals //
  initial begin
    tb_clk = 1'b0;
    tb_symbol_clk = 1'b0;
    tb_mode = 2'd1;
    tb_switch_clk_cycles = tb_clk_f / tb_symbol_clk_f;
    
    tb_rst = 1'b0;
    #(tb_clk_p);
    tb_rst = 1'b1;
    
    #(2*tb_symbol_clk_p);
    @(posedge tb_symbol_clk);
    tb_mode = 2'd2;
    #(2*tb_symbol_clk_p);
    @(posedge tb_symbol_clk);
    tb_mode = 2'd3;
    #(2*tb_symbol_clk_p);
    @(posedge tb_symbol_clk);
    $finish();
  end
  ////////////////////////////
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  
endmodule