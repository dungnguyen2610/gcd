# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import random
from pathlib import Path

import cocotb
import cocotb_bus
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge, Timer, ReadOnly, NextTimeStep
from cocotb_bus.drivers import BusDriver

from gcd_model import gcd_model
def sb_fn(actual_value):
    global expected_value
    assert actual_value == expected_value.pop(0), "Scoreboard Matching Failed"

@cocotb.test()
async def random_test(dut):
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))
    global expected_value
    expected_value = []
    #reset
    await RisingEdge(dut.clk_i)
    dut.rst_ni.value = 1
    await Timer (1, "ns")
    dut.rst_ni.value = 0
    await Timer(1, "ns")
    dut.rst_ni.value = 1
    await RisingEdge(dut.clk_i)

    adriver = InputDriver(dut, "a", dut.clk_i)
    adriver.append(12)
    bdriver = InputDriver(dut, "b", dut.clk_i)
    bdriver.append(5)
    OutputDriver(dut, "y", dut.clk_i, sb_fn)

    #a = random.randint(0, 15)
    #b = random.randint(0, 15)
    expected_value.append(gcd_model(12,5))


class InputDriver(BusDriver):
    _signals = ["rdy", "en", "data"]

    def __init__(self, dut, name, clk):
        BusDriver.__init__(self, dut, name, clk)
        self.bus.en.value = 0
        self.bus.data.value = 0
        self.clk = clk

    async def _driver_send(self, value, sync=True):
        for i in range (10):
            if self.bus.rdy.value == 0:
                await RisingEdge(self.clk)
            else: break
        self.bus.en.value = 1
        self.bus.data.value = value
        #await ReadOnly()
        await RisingEdge(self.clk)
        self.bus.en.value = 0
        #await NextTimeStep()


class OutputDriver(BusDriver):
    _signals = ["rdy", "en", "data"]

    def __init__(self, dut, name, clk, sb_callback):
        BusDriver.__init__(self, dut, name, clk)
        self.bus.en.value = 0
        self.clk = clk
        self.callback = sb_callback
        self.append(0)

    async def _driver_send(self, value, sync=True):
        while True:
            for i in range(random.randint(0, 20)):
                await RisingEdge(self.clk)
            if self.bus.rdy.value != 1:
                await RisingEdge(self.bus.rdy)
            self.bus.en.value = 1
            await ReadOnly()
            self.callback(self.bus.data.value)
            await RisingEdge(self.clk)
            await NextTimeStep()
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

