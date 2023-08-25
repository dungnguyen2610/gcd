module ifc_gcd(
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic [3:0] a_data,
  input  logic [3:0] b_data,
  input  logic       a_en,
  input  logic       b_en,
  input  logic       y_en,

  output logic       a_rdy,
  output logic       b_rdy,
  output logic       y_rdy,
  output logic [3:0] y_data
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
    .op_a_i         (a_data),
    .op_b_i         (b_data),
    .a_en           (a_en),
    .b_en           (b_en),
    .busy_i         (busy),
    .valid_i        (valid),
    .result_val_i   (result_val),
    .result_val_o   (y_data),
    .a_o            (a_data_mas_to_sla),
    .b_o            (b_data_mas_to_sla),
    .clk_i          (clk_i),
    .req_o          (req)
  );

  assign a_rdy = !busy;
  assign b_rdy = !busy;
  assign y_rdy = valid;

// Dump waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, ifc_gcd);
  end

endmodule
