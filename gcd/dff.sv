// This file is public domain, it can be freely copied without restrictions.
// SPDX-License-Identifier: CC0-1.0


module dff (
  input logic clk_i,
  input logic en,
  input logic [3:0] d,
  output logic[3:0] q
);

always_ff @(posedge clk_i) begin
  if (en)  q <= d;
  else     q <= 0;
end

endmodule: dff
