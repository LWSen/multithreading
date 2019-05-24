`include "e203_defines.v"

module e203_context_switch(
  input [`E203_THREADS_NUM-1:0] exu_thread_sel,
  input allow_switch,
  input dbg_mode,
  input commit_trap,
  input commit_mret,
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
    if(~rst_n | ~allow_switch | switch_en) cycles = 0;
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

  /*
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
  */
  wire excp_handling_set = commit_trap;
  wire excp_handling_clr = commit_mret;
  wire excp_handling_en = excp_handling_set | excp_handling_clr;
  wire excp_handling;
  wire excp_handling_next = excp_handling_set | (~excp_handling_clr);
  sirv_gnrl_dfflr #(1) excp_handling_dfflr(excp_handling_en, excp_handling_next, excp_handling, clk, rst_n);
  
  //assign switch_en = ((long_inst & (~switch_lock)) | new_slice) & (~bjp);
  wire thread_same = (thread_sel==exu_thread_sel);
  wire trap_switch = commit_trap & ~thread_same;
  assign switch_en = allow_switch & (new_slice | trap_switch) & (~ifetch_wait) & (~excp_handling) & (~dbg_mode);
  
  assign thread_sel_next[0] = thread_sel[0]^switch_en;
  assign thread_sel_next[1] = thread_sel[1]^switch_en;

  sirv_gnrl_dfflr_init #(`E203_THREADS_NUM, `E203_THREADS_NUM'b01) thread_sel_dff (switch_en, thread_sel_next, thread_sel, clk, rst_n);

endmodule
