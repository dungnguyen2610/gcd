module mux21(
  input  logic [3:0] in0,
  input  logic [3:0] in1,
  input  logic       sel,
  output logic [3:0] out
);

assign out = sel? in1: in0;

endmodule: mux21
