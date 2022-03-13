import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotbext.uart import UartSource, UartSink

@cocotb.test()
async def test_uart_loopback(dut):
    # start a 12 MHz clock
    clock = Clock(dut.clock, round(1e3/12), units="ns")
    cocotb.start_soon(clock.start())

    uart_tx = UartSource(dut.serial_rx, baud=9600, bits=8)
    uart_rx = UartSink(dut.serial_tx, baud=9600, bits=8)

    # wait for loopback to come out of reset
    await Timer(5, units="us")

    dut._log.info("begin uart loopback test")

    values = [random.randint(0,2**8-1) for i in range(10)]

    await uart_tx.write(values)
    await uart_tx.wait()

    dut._log.info("sent:")
    for v in values:
        dut._log.info("  {:x}".format(v))

    recv = []
    while len(recv) < len(values):
        recv += await uart_rx.read()
        dut._log.info("received bytes, length is {}".format(len(recv)))

    dut._log.info("received:")
    for r in recv:
        dut._log.info("  {:x}".format(r))

    assert recv == values
