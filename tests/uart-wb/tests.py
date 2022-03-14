import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles
from cocotbext.uart import UartSource, UartSink
from cocotbext.wishbone.monitor import WishboneSlave
from cocotbext.wishbone.driver import WBOp

def incrementing():
    n = 1;
    while True:
        yield n
        n += 1

@cocotb.test()
async def test_uart_to_wishbone(dut):
    # start a 12 MHz clock
    clock = Clock(dut.clock, round(1e3/12), units="ns")
    cocotb.start_soon(clock.start())

    wb_dev = WishboneSlave(dut, None, dut.clock,
                           width=32,
                           signals_dict={"cyc":  "cyc_out",
                                         "stb":  "strobe_out",
                                         "we":   "we_out",
                                         "adr":  "addr_out",
                                         "datwr":"data_out",
                                         "datrd":"data_in",
                                         "ack":  "ack_in"
                                        },
                           datgen=incrementing())

    uart_tx = UartSource(dut.serial_rx, baud=9600, bits=8)
    uart_rx = UartSink(dut.serial_tx, baud=9600, bits=8)

    # reset
    dut.reset.value = 1
    await ClockCycles(dut.clock, 32)
    dut.reset.value = 0

    dut._log.info("begin uart<->wb test")

    # send write request
    await uart_tx.write([0x1])
    await uart_tx.write([0x0, 0x0, 0x0, 0x1])
    await uart_tx.write([0x1, 0x2, 0x3, 0x4])
    await uart_tx.wait()

    # wait for ack
    await uart_rx.read(count=1)

    # send read request
    await uart_tx.write([0x0])
    await uart_tx.write([0x0, 0x0, 0x0, 0x1])
    await uart_tx.wait()

    # wait for response
    recv = []
    while len(recv) < 4:
        recv += await uart_rx.read()
        dut._log.info("received bytes, length is {}".format(len(recv)))

    # print monitored wishbone transactions
    for reqs in wb_dev._recvQ:
        for req in reqs:
            # req.to_dict?
            print("addr : 0x{:x}".format(req.adr.integer))
            print("datrd: 0x{:x}".format(req.datrd))
            print("datwr: {}".format(hex(req.datwr) if req.datwr else None))
