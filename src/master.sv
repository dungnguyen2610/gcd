module master(
  input  logic [3:0] op_a_i,
  input  logic [3:0] op_b_i,
  input  logic       a_en,
  input  logic       b_en,
  input  logic       busy_i,
  input  logic       valid_i,
  input  logic [3:0] result_val_i,

  output logic [3:0] result_val_o,
  output logic [3:0] a_o,
  output logic [3:0] b_o,
  output logic       req_o,

  input  logic       clk_i
);
always_ff @(posedge clk_i) begin
  if (a_en)  a_o <= op_a_i;
  else if (req_o) a_o <= 0;
  else a_o <= a_o;

  if (b_en)  b_o <= op_b_i;
  else if (req_o) b_o <= 0;
  else b_o <= b_o;
end

always_ff @(posedge clk_i) begin
    if ((a_o != 0) && (b_o != 0))
      req_o <= 1'b1;
    else if (!busy_i)
      req_o <= 1'b0;
    else req_o <= 0;
end

assign result_val_o = valid_i ? result_val_i : 0;

endmodule
