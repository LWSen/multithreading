`include "e203_defines.v"

module e203_exu_oitf_top(
  input  [`E203_THREADS_NUM-1:0] ifu_thread_sel,
  input  [`E203_THREADS_NUM-1:0] exu_thread_sel,
  input  [`E203_THREADS_NUM-1:0] lsu_thread_sel,

  output dis_ready,

  input  dis_ena,
  input  ret_ena,

  output [`E203_ITAG_WIDTH-1:0] dis_ptr,
  output [`E203_ITAG_WIDTH-1:0] ret_ptr,

  output [`E203_RFIDX_WIDTH-1:0] ret_rdidx,
  output ret_rdwen,
  output ret_rdfpu,
  output [`E203_PC_SIZE-1:0] ret_pc,

  input  disp_i_rs1en,
  input  disp_i_rs2en,
  input  disp_i_rs3en,
  input  disp_i_rdwen,
  input  disp_i_rs1fpu,
  input  disp_i_rs2fpu,
  input  disp_i_rs3fpu,
  input  disp_i_rdfpu,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs3idx,
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx,
  input  [`E203_PC_SIZE    -1:0] disp_i_pc,

  output oitfrd_match_disprs1,
  output oitfrd_match_disprs2,
  output oitfrd_match_disprs3,
  output oitfrd_match_disprd,

  output ifu_oitf_empty,
  output exu_oitf_empty,
  output lsu_oitf_empty,
  input  clk,
  input  rst_n
);

  wire [`E203_THREADS_NUM-1:0] dis_ena_top;
  wire [`E203_THREADS_NUM-1:0] ret_ena_top;

  wire [`E203_THREADS_NUM-1:0] disp_i_rs1en_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rs2en_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rs3en_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rdwen_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rs1fpu_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rs2fpu_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rs3fpu_top;
  wire [`E203_THREADS_NUM-1:0] disp_i_rdfpu_top;

  wire [`E203_THREADS_NUM-1:0] dis_ready_top;
  wire [`E203_ITAG_WIDTH-1:0] dis_ptr_top [`E203_THREADS_NUM-1:0];
  wire [`E203_ITAG_WIDTH-1:0] ret_ptr_top [`E203_THREADS_NUM-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] ret_rdidx_top [`E203_THREADS_NUM-1:0];
  wire [`E203_THREADS_NUM-1:0] ret_rdwen_top;
  wire [`E203_THREADS_NUM-1:0] ret_rdfpu_top;
  wire [`E203_PC_SIZE-1:0] ret_pc_top [`E203_THREADS_NUM-1:0];

  wire [`E203_THREADS_NUM-1:0] oitfrd_match_disprs1_top;
  wire [`E203_THREADS_NUM-1:0] oitfrd_match_disprs2_top;
  wire [`E203_THREADS_NUM-1:0] oitfrd_match_disprs3_top;
  wire [`E203_THREADS_NUM-1:0] oitfrd_match_disprd_top;

  wire [`E203_THREADS_NUM-1:0] oitf_empty_top;

  genvar i;
  generate 
    for(i=0;i<`E203_THREADS_NUM;i=i+1) begin
      assign dis_ena_top[i] = dis_ena & exu_thread_sel[i];
      assign ret_ena_top[i] = ret_ena & lsu_thread_sel[i];
      assign disp_i_rs1en_top[i] = disp_i_rs1en & exu_thread_sel[i];
      assign disp_i_rs2en_top[i] = disp_i_rs2en & exu_thread_sel[i];
      assign disp_i_rs3en_top[i] = disp_i_rs3en & exu_thread_sel[i];
      assign disp_i_rdwen_top[i] = disp_i_rdwen & exu_thread_sel[i];
      assign disp_i_rs1fpu_top[i] = disp_i_rs1fpu & exu_thread_sel[i];
      assign disp_i_rs2fpu_top[i] = disp_i_rs2fpu & exu_thread_sel[i];
      assign disp_i_rs3fpu_top[i] = disp_i_rs3fpu & exu_thread_sel[i];
      assign disp_i_rdfpu_top[i] = disp_i_rdfpu & exu_thread_sel[i];
      
      e203_exu_oitf u_e203_exu_oitf(
        .dis_ready            (dis_ready_top[i]),
        .dis_ena              (dis_ena_top[i]  ),
        .ret_ena              (ret_ena_top[i]  ),

        .dis_ptr              (dis_ptr_top[i]  ),

        .ret_ptr              (ret_ptr_top[i]  ),
        .ret_rdidx            (ret_rdidx_top[i]),
        .ret_rdwen            (ret_rdwen_top[i]),
        .ret_rdfpu            (ret_rdfpu_top[i]),
        .ret_pc               (ret_pc_top[i]),

        .disp_i_rs1en         (disp_i_rs1en_top[i]),
        .disp_i_rs2en         (disp_i_rs2en_top[i]),
        .disp_i_rs3en         (disp_i_rs3en_top[i]),
        .disp_i_rdwen         (disp_i_rdwen_top[i] ),
        .disp_i_rs1idx        (disp_i_rs1idx),
        .disp_i_rs2idx        (disp_i_rs2idx),
        .disp_i_rs3idx        (disp_i_rs3idx),
        .disp_i_rdidx         (disp_i_rdidx ),
        .disp_i_rs1fpu        (disp_i_rs1fpu_top[i]),
        .disp_i_rs2fpu        (disp_i_rs2fpu_top[i]),
        .disp_i_rs3fpu        (disp_i_rs3fpu_top[i]),
        .disp_i_rdfpu         (disp_i_rdfpu_top[i] ),
        .disp_i_pc            (disp_i_pc ),

        .oitfrd_match_disprs1 (oitfrd_match_disprs1_top[i]),
        .oitfrd_match_disprs2 (oitfrd_match_disprs2_top[i]),
        .oitfrd_match_disprs3 (oitfrd_match_disprs3_top[i]),
        .oitfrd_match_disprd  (oitfrd_match_disprd_top[i] ),

        .oitf_empty           (oitf_empty_top[i]    ),

        .clk                  (clk           ),
        .rst_n                (rst_n         ) 
      );
    end
  endgenerate

  assign dis_ready = |(dis_ready_top & exu_thread_sel);
  
  assign dis_ptr = (dis_ptr_top[0] & {`E203_ITAG_WIDTH{exu_thread_sel[0]}}) |
                   (dis_ptr_top[1] & {`E203_ITAG_WIDTH{exu_thread_sel[1]}});
                   
  assign ret_ptr = (ret_ptr_top[0] & {`E203_ITAG_WIDTH{lsu_thread_sel[0]}}) |
                   (ret_ptr_top[1] & {`E203_ITAG_WIDTH{lsu_thread_sel[1]}});

  assign ret_rdidx = (ret_rdidx_top[0] & {`E203_RFIDX_WIDTH{lsu_thread_sel[0]}}) |
                     (ret_rdidx_top[1] & {`E203_RFIDX_WIDTH{lsu_thread_sel[1]}});
  
  assign ret_rdwen = |(ret_rdwen_top & lsu_thread_sel);
  
  assign ret_rdfpu = |(ret_rdfpu_top & lsu_thread_sel);
  
  assign ret_pc = (ret_pc_top[0] & {`E203_PC_SIZE{lsu_thread_sel[0]}}) |
                  (ret_pc_top[1] & {`E203_PC_SIZE{lsu_thread_sel[1]}});
  
  assign oitfrd_match_disprs1 = |(oitfrd_match_disprs1_top & exu_thread_sel);  
  assign oitfrd_match_disprs2 = |(oitfrd_match_disprs2_top & exu_thread_sel);
  assign oitfrd_match_disprs3 = |(oitfrd_match_disprs3_top & exu_thread_sel);
  assign oitfrd_match_disprd  = |(oitfrd_match_disprd_top  & exu_thread_sel);
  
  assign ifu_oitf_empty = |(oitf_empty_top & ifu_thread_sel);
  assign exu_oitf_empty = |(oitf_empty_top & exu_thread_sel);
  assign lsu_oitf_empty = |(oitf_empty_top & lsu_thread_sel);
  
endmodule
