module gcdControl (
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic  req_i,
  input  logic  b_zero,
  input  logic  a_lt_b,

  output logic  busy_o,
  output logic  valid_o,
  output logic  a_en_o,
  output logic  b_en_o,
  output logic  [1:0]  a_mux_sel_o,
  output logic  b_mux_sel_o
);

  typedef enum logic [1:0] {
    WAIT = 2'd0,
    CALC = 2'd1,
    DONE = 2'd2
  } fsm_state;

  fsm_state state, next_state;

  //Next state logic
  always_comb begin
    case (state)
      WAIT: begin
        if (req_i) begin
          next_state = CALC;
        end
        else  next_state = WAIT;
      end

      CALC: begin
        if (b_zero)       next_state = DONE;
        else              next_state = CALC;
      end

      DONE: begin
        next_state = WAIT;
      end

      default :begin
      end
    endcase
  end

  //State update logic
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state <= WAIT;
    end
    else      state <= next_state;
  end

  //Output logic
  always_comb begin
    case (state)
      WAIT: begin
        valid_o = 1'b0;
        busy_o  = 1'b0;
        a_en_o  = 1'b1;
        b_en_o  = 1'b1;
        a_mux_sel_o = 2'd0;
        b_mux_sel_o = 1'b0;
      end
      CALC: begin
        valid_o = 1'b0;
        busy_o  = 1'b1;
        if(a_lt_b) begin
          a_en_o  = 1'b1;
          b_en_o  = 1'b1;
          a_mux_sel_o = 2'd1;
          b_mux_sel_o = 1'b1;
        end
        else if (!b_zero) begin
          a_en_o  = 1'b1;
          b_en_o  = 1'b0;
          a_mux_sel_o = 2'd2;
          b_mux_sel_o = 1'bx; //tuy dinh
        end
        else begin
          a_en_o  = 1'b0;
          b_en_o  = 1'b0;
          a_mux_sel_o = 2'dx;
          b_mux_sel_o = 1'bx;
        end
      end
      DONE: begin
        valid_o = 1'b1;
        busy_o  = 1'b1;
        a_en_o  = 1'b0;
        b_en_o  = 1'b0;
        a_mux_sel_o = 2'd0;
        b_mux_sel_o = 1'b0;
      end
      default :begin
      end
    endcase
  end

endmodule
