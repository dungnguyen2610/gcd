module FIFO
#(
  parameter DEPTH  =  8,
  parameter DATA_WIDTH  =  4
)(
  input  logic  clk_i, rst_ni,
  input  logic  wr_en, rd_en,
  input  logic  [DATA_WIDTH-1:0] data_i,
  output logic  [DATA_WIDTH-1:0] data_o
);

  logic [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  logic [DATA_WIDTH-1:0] fifo [DEPTH];
  logic full, empty;
  //Set default value when reset
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      w_ptr  <= 0;
      r_ptr  <= 0;
      data_o <= 0;
     // fifo   <= 0;
    end
  end

  //Write data to FIFO
  always_ff @(posedge clk_i) begin
    if  (wr_en & !full)  begin
      fifo[w_ptr] <= data_i;
      w_ptr <= w_ptr + 1;
    end
  end

  //Read data from FIFO
  always_ff @(posedge clk_i) begin
    if  (rd_en & !empty)  begin
      data_o <= fifo[r_ptr];
      r_ptr  <= r_ptr + 1;
    end
  end

  assign full  = ((w_ptr == 3'd7) & (r_ptr == 3'd0));
  assign empty = (w_ptr == r_ptr);
endmodule
