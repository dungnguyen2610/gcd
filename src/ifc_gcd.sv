module ifc_gcd (
  input  logic  [3:0] a_data,
  input  logic        a_en  ,
  input  logic  [3:0] b_data,
  input  logic        b_en  ,
  input  logic        y_en  ,
  input  logic        clk_i ,
  input  logic        rst_ni,

  output logic        b_rdy ,
  output logic  [3:0] y_data,
  output logic        a_rdy ,
  output logic        y_rdy
);
logic [3:0] a,b,result;
logic a_full, b_full, busy, valid, y_empty;

FIFO1 data_a (
  .clk_i    (clk_i),
  .rst_ni   (rst_ni),
  .wr_en    (a_en),
  .rd_en    (!busy),
  .data_i   (a_data),
  .full_o   (a_full),
  .data_o   (a)
);

FIFO1 data_b (
  .clk_i    (clk_i),
  .rst_ni   (rst_ni),
  .wr_en    (b_en),
  .rd_en    (!busy),
  .data_i   (b_data),
  .full_o   (b_full),
  .data_o   (b)
);

gcd GCD (
  .clk_i        (clk_i),
  .rst_ni       (rst_ni),
  .a_i          (a),
  .b_i          (b),
  .busy_o       (busy),
  .valid_o      (valid),
  .result_val_o (result)
);

FIFO2 data_y (
  .clk_i    (clk_i),
  .rst_ni   (rst_ni),
  .wr_en    (valid),
  .rd_en    (y_en),
  .data_i   (result),
  .empty_o  (y_empty),
  .data_o   (y_data)
);

assign a_rdy = (!a_full);
assign b_rdy = (!b_full);
assign y_rdy = (!y_empty);

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, ifc_gcd);
  end

endmodule
