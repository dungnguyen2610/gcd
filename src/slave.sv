module slave (
  input  logic       clk_i,rst_ni,
  input  logic [3:0] op_a_i, op_b_i,
  input  logic       req_i,

  output logic [3:0] result_val_o,
  output logic       busy_o, valid_o
);
  //declare variable
  logic b_zero, a_lt_b, a_en, b_en, b_mux_sel;
  logic [1:0] a_mux_sel;

  gcdControl control (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .req_i        (req_i),
    .b_zero       (b_zero),
    .a_lt_b       (a_lt_b),
    .busy_o       (busy_o),
    .valid_o      (valid_o),
    .a_en_o       (a_en),
    .b_en_o       (b_en),
    .a_mux_sel_o  (a_mux_sel),
    .b_mux_sel_o  (b_mux_sel)
  );

  gcdDatapath datapath (
    .clk_i        (clk_i),
    .op_a         (op_a_i),
    .op_b         (op_b_i),
    .a_mux_sel    (a_mux_sel),
    .b_mux_sel    (b_mux_sel),
    .a_en         (a_en),
    .b_en         (b_en),
    .result_data  (result_val_o),
    .b_zero       (b_zero),
    .a_lt_b       (a_lt_b)
  );
endmodule
