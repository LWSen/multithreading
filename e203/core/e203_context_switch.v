`include "e203_defines.v"

module e203_context_switch(
  input long_inst,
  input bjp,
  input ifetch_wait,
  output switch_en,
  output [`E203_THREADS_NUM-1:0] thread_sel,
  output [`E203_THREADS_NUM-1:0] thread_sel_next,
  input clk,
  input rst_n
);

  localparam TIME_SLICE = 10'h3FF;
  reg [9:0] cycles;
  wire new_slice = (cycles==TIME_SLICE);
  
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n | switch_en) cycles = 0;
    else begin
      if(new_slice) cycles = TIME_SLICE;
      else cycles = cycles+1;
    end
  end
  
  
  wire [`E203_THREADS_NUM-1:0] switch_flag_set;
  wire [`E203_THREADS_NUM-1:0] switch_flag_clr;
  wire [`E203_THREADS_NUM-1:0] switch_flag_en;
  wire [`E203_THREADS_NUM-1:0] switch_flag;
  wire [`E203_THREADS_NUM-1:0] switch_flag_next;

  genvar i;
  generate
    for(i=0;i<`E203_THREADS_NUM;i=i+1) begin
      assign switch_flag_set[i] = thread_sel[i] & switch_en;
      assign switch_flag_clr[i] = new_slice;
      assign switch_flag_en[i] = switch_flag_set[i] | switch_flag_clr[i];
      assign switch_flag_next[i] = switch_flag_set[i] | (~switch_flag_clr[i]);
      sirv_gnrl_dfflr #(1) switch_flag_dfflr(switch_flag_en[i], switch_flag_next[i], switch_flag[i], clk, rst_n);
    end
  endgenerate

  wire switch_lock = (thread_sel[0] & switch_flag[0]) |
                     (thread_sel[1] & switch_flag[1]);

  //assign switch_en = ((long_inst & (~switch_lock)) | new_slice) & (~bjp);

  assign switch_en = new_slice & (~bjp) & (~ifetch_wait);
  
  assign thread_sel_next[0] = thread_sel[0]^switch_en;
  assign thread_sel_next[1] = thread_sel[1]^switch_en;

  sirv_gnrl_dfflr_init #(`E203_THREADS_NUM, `E203_THREADS_NUM'b01) thread_sel_dff (switch_en, thread_sel_next, thread_sel, clk, rst_n);

endmodule
