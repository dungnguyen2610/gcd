module gcd(
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic [3:0] a_i,
  input  logic [3:0] b_i,
  output logic       busy_o,
  output logic       valid_o,
  output logic [3:0] result_val_o
);

  logic [3:0] a_data_mas_to_sla, b_data_mas_to_sla, result_val;
  logic req, busy, valid;

  slave slv(
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .op_a_i         (a_data_mas_to_sla),
    .op_b_i         (b_data_mas_to_sla),
    .req_i          (req),
    .busy_o         (busy),
    .valid_o        (valid),
    .result_val_o   (result_val)
  );

  master mter(
    .op_a_i         (a_i),
    .op_b_i         (b_i),
    .busy_i         (busy),
    .valid_i        (valid),
    .result_val_i   (result_val),
    .result_val_o   (result_val_o),
    .a_o            (a_data_mas_to_sla),
    .b_o            (b_data_mas_to_sla),
    .clk_i          (clk_i),
    .req_o          (req)
  );

  assign busy_o = busy;
  assign valid_o = valid;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, top);
  end
endmodule
