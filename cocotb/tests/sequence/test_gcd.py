# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge, Timer, Edge
from cocotb.types import LogicArray

from gcd_model import gcd_model

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
        await RisingEdge(dut.clk_i)
        if (dut.y_rdy.value == 1):
            dut.y_en.value = 1
            await RisingEdge(dut.clk_i)
            break
        else: dut.y_en.value = 0
    await RisingEdge(dut.clk_i)
    assert dut.y_data.value == gcd_model(A,B), "fail"

@cocotb.test()
async def random_test(dut):
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))




def test_runner():
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent.parent
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "cocotb" / "env"))

    verilog_sources = []

    if hdl_toplevel_lang == "verilog":
        verilog_sources += [proj_path / "src" / "ifc_gcd.sv"]

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "cocotb" / "tests" /"sequence"))

    runner = get_runner(sim)
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="top",
        always=True,
    )
    runner.test(hdl_toplevel="ifc_gcd", test_module="test_gcd")


if __name__ == "__main__":
    test_runner()

