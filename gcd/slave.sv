module slave (
  input  logic       clk_i,rst_ni,
  input  logic [3:0] op_a_i, op_b_i,
  input  logic       req_i,

  output logic [3:0] result_val_o,
  output logic       busy_o, valid_o
);
  //declare variable
  logic [3:0] A;
  logic [3:0] B;
  logic [3:0] sub_ab;
  logic [3:0] outa;
  logic [3:0] outb;
  logic [1:0] a_sel;
  logic       b_sel;

  typedef enum logic [1:0] {
    WAIT = 2'd0,
    CALC = 2'd1,
    DONE = 2'd2
  } fsm_state;

  fsm_state state, next_state;

  always_comb begin
      case (state)
        WAIT: begin
          valid_o = 1'b0;
          busy_o  = 1'b0;
          if (req_i) begin
            next_state = CALC;
            a_sel = 2'd0;
            b_sel = 1'b0;
          end
          else  next_state = WAIT;
        end

        CALC: begin
          valid_o = 1'b0;
          busy_o  = 1'b1;
          if (b_zero) begin
            next_state = DONE;
          end
          else if (a_lt) begin
            a_sel = 2'd1;
            b_sel = 1'b1;
            next_state = CALC;
          end
          else begin
            a_sel = 2'd2;
            b_sel = 1'b1;
            next_state = CALC;
          end
        end
        DONE: begin
          valid_o = 1'b1;
          busy_o  = 1'b0;
          next_state = WAIT;
        end
      endcase
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni)  state <= WAIT;
    else      state <= next_state;
  end

  mux41 muxa(
    .in0(op_a_i),
    .in1(B),
    .in2(sub_ab),
    .in3(4'd0),
    .sel(a_sel),
    .out(outa)
  );

  mux21 muxb(
    .in0(op_b_i),
    .in1(A),
    .sel(b_sel),
    .out(outb)
  );

  dff a_ff(
    .clk_i(clk_i),
    .en(1'b1),
    .d(outa),
    .q(A)
  );

  dff b_ff(
    .clk_i(clk_i),
    .en(1'b1),
    .d(outb),
    .q(B)
  );
  assign b_zero = (B == 0);
  assign a_lt   = ((A < B) ? 1 : 0);
  assign sub_ab = A - B;
  assign result_val_o  = A;

endmodule
