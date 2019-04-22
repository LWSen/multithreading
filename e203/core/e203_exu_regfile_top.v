 

module e203_exu_regfile_top(
  input  [`E203_THREADS_NUM-1:0] ifu_read_thread_sel,
  
  input  [`E203_THREADS_NUM-1:0] exu_read_thread_sel,
  input  [`E203_RFIDX_WIDTH-1:0] read_src1_idx,
  input  [`E203_RFIDX_WIDTH-1:0] read_src2_idx,
  output [`E203_XLEN-1:0]        read_src1_dat,
  output [`E203_XLEN-1:0]        read_src2_dat,

  input  [`E203_THREADS_NUM-1:0] wbck_thread_sel,
  input  wbck_dest_wen,
  input  [`E203_RFIDX_WIDTH-1:0] wbck_dest_idx,
  input  [`E203_XLEN-1:0] wbck_dest_dat,

  output [`E203_XLEN-1:0] x1_r,

  input  test_mode,
  input  clk,
  input  rst_n
  );

  
  wire [`E203_THREADS_NUM-1:0] rf_wen;
  wire [`E203_XLEN-1:0] rf_read_src1_dat[`E203_THREADS_NUM-1:0];
  wire [`E203_XLEN-1:0] rf_read_src2_dat[`E203_THREADS_NUM-1:0];
  wire [`E203_XLEN-1:0] rf_x1_r[`E203_THREADS_NUM-1:0];
  
  genvar i;
  generate
    for(i=0;i<`E203_THREADS_NUM;i=i+1) begin
      assign rf_wen[i] = wbck_dest_wen & wbck_thread_sel[i];
      
      e203_exu_regfile u_e203_exu_regfile(
	      .read_src1_idx (read_src1_idx ),
	      .read_src2_idx (read_src2_idx ),
	      .read_src1_dat (rf_read_src1_dat[i]),
	      .read_src2_dat (rf_read_src2_dat[i]),
	      
	      .x1_r          (rf_x1_r[i]),
		              
	      .wbck_dest_wen (rf_wen[i]),
	      .wbck_dest_idx (wbck_dest_idx),
	      .wbck_dest_dat (wbck_dest_dat),
		                           
	      .test_mode     (test_mode),
	      .clk           (clk          ),
	      .rst_n         (rst_n        ) 
	    );
    end
  endgenerate

  

  assign read_src1_dat = ({`E203_XLEN{exu_read_thread_sel[0]}} & rf_read_src1_dat[0]) |
                         ({`E203_XLEN{exu_read_thread_sel[1]}} & rf_read_src1_dat[1]);
  assign read_src2_dat = ({`E203_XLEN{exu_read_thread_sel[0]}} & rf_read_src2_dat[0]) |
                         ({`E203_XLEN{exu_read_thread_sel[1]}} & rf_read_src2_dat[1]);
  assign x1_r = ({`E203_XLEN{ifu_read_thread_sel[0]}} & rf_x1_r[0]) |
                ({`E203_XLEN{ifu_read_thread_sel[1]}} & rf_x1_r[1]);

endmodule
