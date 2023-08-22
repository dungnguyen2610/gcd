module master(
  input  logic [3:0] op_a_i,
  input  logic [3:0] op_b_i,
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
    if ((op_a_i != 0) && (op_b_i != 0))
      req_o <= 1'b1;
    else if (!busy_i)
      req_o <= 1'b0;
end

assign result_val_o = valid_i ? result_val_i : 0;
assign a_o = busy_i ? 0 : op_a_i;
assign b_o = busy_i ? 0 : op_b_i;

endmodule
