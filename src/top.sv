module top(
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic [3:0] a_i,
  input  logic [3:0] b_i,
  output logic [3:0] result_val_o
);

  logic [3:0] a_tmp, b_tmp, result_val, data_a, data_b;
  logic req, busy, valid;

  FIFO value_a (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .wr_en  (1'b1),
    .rd_en  (1'b1),
    .data_i (a_i),
    .data_o (data_a)
  );

  FIFO value_b (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .wr_en  (1'b1),
    .rd_en  (1'b1),
    .data_i (b_i),
    .data_o (data_b)
  );

  slave slv(
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .op_a_i         (a_tmp),
    .op_b_i         (b_tmp),
    .req_i          (req),
    .busy_o         (busy),
    .valid_o        (valid),
    .result_val_o   (result_val)
  );

  master mter(
    .op_a_i         (data_a),
    .op_b_i         (data_b),
    .busy_i         (busy),
    .valid_i        (valid),
    .result_val_i   (result_val),
    .result_val_o   (result_val_o),
    .a_o            (a_tmp),
    .b_o            (b_tmp),
    .clk_i          (clk_i),
    .req_o          (req)
  );
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, top);
  end
endmodule
