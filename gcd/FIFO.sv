module FIFO
#(
  parameter DEPTH  =  8,
  parameter DATA_WIDTH  =  4
)(
  input  logic  clk_i, rst_ni,
  input  logic  wr_en, rd_en,
  input  logic  [DATA_WIDTH-1:0] data_i,
  output logic  [DATA_WIDTH-1:0] data_o
);

  logic [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  logic [DATA_WIDTH-1:0] fifo [DEPTH];
  logic full, empty;
  //Set default value when reset
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      w_ptr  <= 0;
      r_ptr  <= 0;
      data_o <= 0;
     // fifo   <= 0;
    end
  end

  //Write data to FIFO
  always_ff @(posedge clk_i) begin
    if  (wr_en & !full)  begin
      fifo[w_ptr] <= data_i;
      w_ptr <= w_ptr + 1;
    end
  end

  //Read data from FIFO
  always_ff @(posedge clk_i) begin
    if  (rd_en & !empty)  begin
      data_o <= fifo[r_ptr];
      r_ptr  <= r_ptr + 1;
    end
  end

  assign full  = ((w_ptr == 3'd7) & (r_ptr == 3'd0));
  assign empty = (w_ptr == r_ptr);
endmodule

@cocotb.test()
async def simple_test(dut):
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    A = 12
    B = 5
    dut.a_data.value = A
    dut.b_data.value = B

    await RisingEdge(dut.clk_i)
    dut.rst_ni.value = 0
    await Timer(1, units = "ns")
    dut.rst_ni.value = 1
    await RisingEdge(dut.clk_i)

    if (dut.b_rdy.value == 1):
        dut.b_en.value = 1
    else: dut.b_en.value = 0

    if (dut.a_rdy == 1):
        dut.a_en.value = 1
    else: dut.a_en.value = 0

    for i in range (20):
        if (dut.y_rdy.value == 1):
            dut.y_en.value = 1
            await RisingEdge(dut.clk_i)
            break
        else:
            dut.y_en.value = 0
            await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    assert dut.y_data.value == gcd_model(A,B), "fail"


