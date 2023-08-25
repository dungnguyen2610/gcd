# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import random
from pathlib import Path
from collections import deque

import cocotb
import cocotb_bus
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge, Timer, ReadOnly, NextTimeStep
from cocotb_bus.drivers import BusDriver

from gcd_model import gcd_model

async def set_up (dut):
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    clkedge  = RisingEdge(dut.clk_i)
    #reset
    dut.rst_ni.value = 1
    await Timer (1, "ns")
    dut.rst_ni.value = 0
    await Timer(1, "ns")
    dut.rst_ni.value = 1
    await clkedge

def call_back(actual_value):
    global expect_value
    assert actual_value == expect_value, "fail"

@cocotb.test()
async def random_test(dut):
    clkedge  = RisingEdge(dut.clk_i)
    global expect_value
    await set_up(dut)

    a = random.randint(0,15)
    b = random.randint(0,15)
    adrv = InputDriver(dut, "a", dut.clk_i)
    bdrv = InputDriver(dut, "b", dut.clk_i)
    await adrv._driver_send(a)
    await bdrv._driver_send(b)

    expect_value = gcd_model(a,b)
    outdata = OutputDriver(dut, "y", dut.clk_i, call_back)
    await outdata._driver_send()


class InputDriver(BusDriver):
    _signals = ["rdy", "en", "data"]

    def __init__(self, dut, name, clk):
        BusDriver.__init__(self, dut, name, clk)
        self.clk = clk

    async def _driver_send(self, transaction, sync=True):
        if self.bus.rdy.value != 1:
            await RisingEdge(self.bus.rdy)
        self.bus.en.value = 1
        self.bus.data.value = transaction
        await RisingEdge(self.clk)
        self.bus.en.value = 0


class OutputDriver(BusDriver):
    _signals = ["rdy", "en", "data"]

    def __init__(self, dut, name, clk, dataout):
        BusDriver.__init__(self, dut, name, clk)
        self.clk = clk
        self.dataout = dataout
        #self.append(0)

    async def _driver_send(self, sync=True):
        if self.bus.rdy.value != 1:
            await RisingEdge(self.bus.rdy)
        self.bus.en.value = 1
        self.dataout = self.bus.data.value
        await RisingEdge(self.clk)
        self.bus.en.value = 0


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

