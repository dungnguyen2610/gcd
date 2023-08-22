module gcdDatapath(
  input  logic  clk_i,
  input  logic  [3: 0] op_a,
  input  logic  [3: 0] op_b,
  input  logic  [1: 0] a_mux_sel,
  input  logic         b_mux_sel,
  input  logic         a_en,
  input  logic         b_en,

  output logic  [3: 0] result_data,
  output logic  b_zero,
  output logic  a_lt_b
);

  logic [3: 0] A, B, sub_ab, a_mux_dataout, b_mux_dataout;
  assign b_zero = (B == 0);
  assign a_lt_b = ((A < B) ? 1 : 0);
  assign sub_ab = A - B;
  assign result_data  = A;

  mux41 muxa(
    .in0(op_a),
    .in1(B),
    .in2(sub_ab),
    .in3(4'd0),
    .sel(a_mux_sel),
    .out(a_mux_dataout)
  );

  mux21 muxb(
    .in0(op_b),
    .in1(A),
    .sel(b_mux_sel),
    .out(b_mux_dataout)
  );

  dff a_ff(
    .clk_i  (clk_i),
    .en     (a_en),
    .d      (a_mux_dataout),
    .q      (A)
  );

  dff b_ff(
    .clk_i  (clk_i),
    .en     (b_en),
    .d      (b_mux_dataout),
    .q      (B)
  );

endmodule
