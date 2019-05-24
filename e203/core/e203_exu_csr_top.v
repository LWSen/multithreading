module e203_exu_csr_top(
  input [`E203_THREADS_NUM-1:0] thread_sel,
  output allow_switch,

  input nonflush_cmt_ena,
  output eai_xs_off,

  input csr_ena,
  input csr_wr_en,
  input csr_rd_en,
  input [12-1:0] csr_idx,

  output csr_access_ilgl,
  output tm_stop,
  output core_cgstop,
  output tcm_cgstop,
  output itcm_nohold,
  output mdv_nob2b,


  output [`E203_XLEN-1:0] read_csr_dat,
  input  [`E203_XLEN-1:0] wbck_csr_dat,
   
  input  [`E203_HART_ID_W-1:0] core_mhartid,
  input  ext_irq_r,
  input  sft_irq_r,
  input  tmr_irq_r,

  output status_mie_r,
  output mtie_r,
  output msie_r,
  output meie_r,

  output wr_dcsr_ena    ,
  output wr_dpc_ena     ,
  output wr_dscratch_ena,


  input [`E203_XLEN-1:0] dcsr_r    ,
  input [`E203_PC_SIZE-1:0] dpc_r     ,
  input [`E203_XLEN-1:0] dscratch_r,

  output [`E203_XLEN-1:0] wr_csr_nxt    ,

  input  dbg_mode,
  input  dbg_stopcycle,

  output u_mode,
  output s_mode,
  output h_mode,
  output m_mode,

  input [`E203_ADDR_SIZE-1:0] cmt_badaddr,
  input cmt_badaddr_ena,
  input [`E203_PC_SIZE-1:0] cmt_epc,
  input cmt_epc_ena,
  input [`E203_XLEN-1:0] cmt_cause,
  input cmt_cause_ena,
  input cmt_status_ena,
  input cmt_instret_ena,

  input                      cmt_mret_ena,
  output[`E203_PC_SIZE-1:0]  csr_epc_r,
  output[`E203_PC_SIZE-1:0]  csr_dpc_r,
  output[`E203_XLEN-1:0]     csr_mtvec_r,

  

  input  clk_aon,
  input  clk,
  input  rst_n

  );

  wire [`E203_THREADS_NUM-1:0] top_nonflush_cmt_ena;
  wire [`E203_THREADS_NUM-1:0] top_csr_ena;
  wire [`E203_THREADS_NUM-1:0] top_csr_wr_en;
  wire [`E203_THREADS_NUM-1:0] top_csr_rd_en;
  wire [`E203_THREADS_NUM-1:0] top_cmt_badaddr_ena;
  wire [`E203_THREADS_NUM-1:0] top_cmt_epc_ena;
  wire [`E203_THREADS_NUM-1:0] top_cmt_cause_ena;
  wire [`E203_THREADS_NUM-1:0] top_cmt_status_ena;
  wire [`E203_THREADS_NUM-1:0] top_cmt_instret_ena;
  wire [`E203_THREADS_NUM-1:0] top_cmt_mret_ena;
  wire [`E203_THREADS_NUM-1:0] top_core_mhartid;

  wire [`E203_THREADS_NUM-1:0] top_eai_xs_off;
  wire [`E203_THREADS_NUM-1:0] top_csr_access_ilgl;
  wire [`E203_THREADS_NUM-1:0] top_tm_stop;
  wire [`E203_THREADS_NUM-1:0] top_core_cgstop;
  wire [`E203_THREADS_NUM-1:0] top_tcm_cgstop;
  wire [`E203_THREADS_NUM-1:0] top_itcm_nohold;
  wire [`E203_THREADS_NUM-1:0] top_mdv_nob2b;
  wire [`E203_XLEN-1:0] top_read_csr_dat[`E203_THREADS_NUM-1:0];
  wire [`E203_THREADS_NUM-1:0] top_status_mie_r;
  wire [`E203_THREADS_NUM-1:0] top_mtie_r;
  wire [`E203_THREADS_NUM-1:0] top_msie_r;
  wire [`E203_THREADS_NUM-1:0] top_meie_r;
  wire [`E203_THREADS_NUM-1:0] top_wr_dcsr_ena    ;
  wire [`E203_THREADS_NUM-1:0] top_wr_dpc_ena     ;
  wire [`E203_THREADS_NUM-1:0] top_wr_dscratch_ena;
  wire [`E203_XLEN-1:0] top_wr_csr_nxt[`E203_THREADS_NUM-1:0];
  wire [`E203_THREADS_NUM-1:0] top_u_mode;
  wire [`E203_THREADS_NUM-1:0] top_s_mode;
  wire [`E203_THREADS_NUM-1:0] top_h_mode;
  wire [`E203_THREADS_NUM-1:0] top_m_mode;
  wire [`E203_PC_SIZE-1:0]  top_csr_epc_r[`E203_THREADS_NUM-1:0];
  wire [`E203_PC_SIZE-1:0]  top_csr_dpc_r[`E203_THREADS_NUM-1:0];
  wire [`E203_XLEN-1:0]     top_csr_mtvec_r[`E203_THREADS_NUM-1:0];
  wire [`E203_THREADS_NUM-1:0] top_allow_switch;
  
  
  genvar i;
  generate
    for(i=0;i<`E203_THREADS_NUM;i=i+1) begin
      assign top_nonflush_cmt_ena[i] = nonflush_cmt_ena & thread_sel[i];
      assign top_csr_ena[i] = csr_ena & thread_sel[i];
      assign top_csr_wr_en[i] = csr_wr_en & thread_sel[i];
      assign top_csr_rd_en[i] = csr_rd_en & thread_sel[i];
      assign top_cmt_badaddr_ena[i] = cmt_badaddr_ena & thread_sel[i];
      assign top_cmt_epc_ena[i] = cmt_epc_ena & thread_sel[i];
      assign top_cmt_cause_ena[i] = cmt_cause_ena & thread_sel[i];
      assign top_cmt_status_ena[i] = cmt_status_ena & thread_sel[i];
      assign top_cmt_instret_ena[i] = cmt_instret_ena & thread_sel[i];
      assign top_cmt_mret_ena[i] = cmt_mret_ena & thread_sel[i];
      assign top_core_mhartid[i] = (i==0) ? 1'b0 : 1'b1;

      e203_exu_csr u_e203_exu_csr(
        .csr_access_ilgl     (top_csr_access_ilgl[i]),
        .eai_xs_off          (top_eai_xs_off[i]),
        .nonflush_cmt_ena    (top_nonflush_cmt_ena[i]),
        .tm_stop             (top_tm_stop[i]),
        .itcm_nohold         (top_itcm_nohold[i]),
        .mdv_nob2b           (top_mdv_nob2b[i]),
        .core_cgstop         (top_core_cgstop[i]),
        .tcm_cgstop          (top_tcm_cgstop[i] ),
        .csr_ena             (top_csr_ena[i]),
        .csr_idx             (csr_idx),
        .csr_rd_en           (top_csr_rd_en[i]),
        .csr_wr_en           (top_csr_wr_en[i]),
        .read_csr_dat        (top_read_csr_dat[i]),
        .wbck_csr_dat        (wbck_csr_dat),
       
        .cmt_badaddr           (cmt_badaddr    ), 
        .cmt_badaddr_ena       (top_cmt_badaddr_ena[i]),
        .cmt_epc               (cmt_epc        ),
        .cmt_epc_ena           (top_cmt_epc_ena[i]    ),
        .cmt_cause             (cmt_cause      ),
        .cmt_cause_ena         (top_cmt_cause_ena[i]  ),
        .cmt_instret_ena       (top_cmt_instret_ena[i]  ),
        .cmt_status_ena        (top_cmt_status_ena[i] ),

        .cmt_mret_ena  (top_cmt_mret_ena[i]     ),
        .csr_epc_r     (top_csr_epc_r[i]       ),
        .csr_dpc_r     (top_csr_dpc_r[i]       ),
        .csr_mtvec_r   (top_csr_mtvec_r[i]     ),

        .wr_dcsr_ena     (top_wr_dcsr_ena[i]    ),
        .wr_dpc_ena      (top_wr_dpc_ena[i]     ),
        .wr_dscratch_ena (top_wr_dscratch_ena[i]),

                                         
        .wr_csr_nxt      (top_wr_csr_nxt[i]    ),
                                         
        .dcsr_r          (dcsr_r         ),
        .dpc_r           (dpc_r          ),
        .dscratch_r      (dscratch_r     ),
                                        
        .dbg_mode       (dbg_mode       ),
        .dbg_stopcycle  (dbg_stopcycle),

        .u_mode        (top_u_mode[i]),
        .s_mode        (top_s_mode[i]),
        .h_mode        (top_h_mode[i]),
        .m_mode        (top_m_mode[i]),

        .core_mhartid  (top_core_mhartid[i]),

        .status_mie_r  (top_status_mie_r[i]),
        .mtie_r        (top_mtie_r[i]      ),
        .msie_r        (top_msie_r[i]      ),
        .meie_r        (top_meie_r[i]      ),

        .ext_irq_r     (ext_irq_r),
        .sft_irq_r     (sft_irq_r),
        .tmr_irq_r     (tmr_irq_r),

        .allow_switch  (top_allow_switch[i]),

        .clk_aon       (clk_aon      ),
        .clk           (clk          ),
        .rst_n         (rst_n        ) 
      );

    end
  endgenerate

  assign eai_xs_off = (thread_sel[0] & top_eai_xs_off[0]) |
                      (thread_sel[1] & top_eai_xs_off[1]);

  assign csr_access_ilgl = (thread_sel[0] & top_csr_access_ilgl[0]) |
                           (thread_sel[1] & top_csr_access_ilgl[1]);

  assign tm_stop = (thread_sel[0] & top_tm_stop[0]) |
                   (thread_sel[1] & top_tm_stop[1]);
  
  assign core_cgstop = (thread_sel[0] & top_core_cgstop[0]) |
                       (thread_sel[1] & top_core_cgstop[1]);

  assign tcm_cgstop = (thread_sel[0] & top_tcm_cgstop[0]) |
                      (thread_sel[1] & top_tcm_cgstop[1]);

  assign itcm_nohold = (thread_sel[0] & top_itcm_nohold[0]) |
                       (thread_sel[1] & top_itcm_nohold[1]);

  assign mdv_nob2b = (thread_sel[0] & top_mdv_nob2b[0]) |
                     (thread_sel[1] & top_mdv_nob2b[1]);

  assign read_csr_dat = ({`E203_XLEN{thread_sel[0]}} & top_read_csr_dat[0]) |
                        ({`E203_XLEN{thread_sel[1]}} & top_read_csr_dat[1]); 

  assign status_mie_r = (thread_sel[0] & top_status_mie_r[0]) |
                        (thread_sel[1] & top_status_mie_r[1]);

  assign mtie_r = (thread_sel[0] & top_mtie_r[0]) |
                  (thread_sel[1] & top_mtie_r[1]);

  assign msie_r = (thread_sel[0] & top_msie_r[0]) |
                  (thread_sel[1] & top_msie_r[1]);

  assign meie_r = (thread_sel[0] & top_meie_r[0]) |
                  (thread_sel[1] & top_meie_r[1]);

  assign wr_dcsr_ena = (thread_sel[0] & top_wr_dcsr_ena[0]) |
                       (thread_sel[1] & top_wr_dcsr_ena[1]);

  assign wr_dpc_ena = (thread_sel[0] & top_wr_dpc_ena[0]) |
                      (thread_sel[1] & top_wr_dpc_ena[1]);

  assign wr_dscratch_ena = (thread_sel[0] & top_wr_dscratch_ena[0]) |
                           (thread_sel[1] & top_wr_dscratch_ena[1]);

  assign wr_csr_nxt = ({`E203_XLEN{thread_sel[0]}} & top_wr_csr_nxt[0]) |
                      ({`E203_XLEN{thread_sel[1]}} & top_wr_csr_nxt[1]); 

  assign u_mode = (thread_sel[0] & top_u_mode[0]) |
                  (thread_sel[1] & top_u_mode[1]);

  assign s_mode = (thread_sel[0] & top_s_mode[0]) |
                  (thread_sel[1] & top_s_mode[1]);

  assign h_mode = (thread_sel[0] & top_h_mode[0]) |
                  (thread_sel[1] & top_h_mode[1]);

  assign m_mode = (thread_sel[0] & top_m_mode[0]) |
                  (thread_sel[1] & top_m_mode[1]);

  assign csr_epc_r = ({`E203_PC_SIZE{thread_sel[0]}} & top_csr_epc_r[0]) |
                     ({`E203_PC_SIZE{thread_sel[1]}} & top_csr_epc_r[1]); 

  assign csr_dpc_r = ({`E203_PC_SIZE{thread_sel[0]}} & top_csr_dpc_r[0]) |
                     ({`E203_PC_SIZE{thread_sel[1]}} & top_csr_dpc_r[1]); 

  assign csr_mtvec_r = ({`E203_XLEN{thread_sel[0]}} & top_csr_mtvec_r[0]) |
                       ({`E203_XLEN{thread_sel[1]}} & top_csr_mtvec_r[1]); 

  assign allow_switch = top_allow_switch[0];

endmodule
