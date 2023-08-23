module FIFO2
#(
  parameter DEPTH  =  8,
  parameter DATA_WIDTH  =  4
)(
  input  logic  clk_i, rst_ni,
  input  logic  wr_en, rd_en,
  input  logic  [DATA_WIDTH-1:0] data_i,
  output logic  empty_o,
  output logic  [DATA_WIDTH-1:0] data_o
);

  logic [$clog2(DEPTH) : 0] w_ptr, r_ptr;
  logic [DATA_WIDTH-1:0] fifo [DEPTH];
  logic full;

  //Set default value when reset
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      w_ptr  <= 0;
      r_ptr  <= 0;
      data_o <= 0;
    end
    else begin
      if  (wr_en & !full)  begin
        fifo[w_ptr[2:0]] <= data_i;
        w_ptr <= w_ptr + 1;
      end
      if  (rd_en & !empty_o)  begin
        data_o <= fifo[r_ptr[2:0]];
        r_ptr  <= r_ptr + 1;
        fifo[r_ptr[2:0]] <= 0;
      end
    end
  end
  assign full  = ({~w_ptr[3], w_ptr[2:0]} == r_ptr);
  assign empty_o = (w_ptr == r_ptr);
endmodule
