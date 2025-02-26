import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

# Define the reset sequence
async def reset_sequence(dut):
    """Applying the Reset"""
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)
    dut.reset.value = 1
    await RisingEdge(dut.clk)

# Apply random inputs to the DUT
async def apply_inputs(dut):
    """Apply random inputs to DUT"""
    dut.dividend.value = random.randint(0, (1 << 32) - 1)
    dut.divisor.value = random.randint(1, (1 << 32) - 1)  # Avoid zero divisor

# Driver function to apply inputs and assert valid
async def driver(dut):
    """Drive the inputs"""
    await apply_inputs(dut)
    dut.valid_in.value = 1
    await RisingEdge(dut.clk)
    dut.valid_in.value = 0
    await RisingEdge(dut.clk)  # Wait for one more clock to settle

# Monitor function to check outputs
async def monitor(dut):
    """Monitor the DUT and check results."""

    # Calculate the expected quotient and remainder
    expected_quotient = int(dut.dividend.value) // int(dut.divisor.value)
    expected_remainder = int(dut.dividend.value) % int(dut.divisor.value)

    # Wait untill the valid_out got high
    while (dut.valid_out.value == 0):
        await RisingEdge(dut.clk)
                                                    
    # Compare the expected and actual outputs
    if int(dut.quotient.value) != expected_quotient or int(dut.remainder.value) != expected_remainder:
        print("ERROR: Test failed!")
        print(f"  Inputs: dividend = {int(dut.dividend.value)}, divisor = {int(dut.divisor.value)}")
        print(f"  Expected: quotient = {expected_quotient}, remainder = {expected_remainder}")
        print(f"  Actual: quotient = {int(dut.quotient.value)}, remainder = {int(dut.remainder.value)}")
        raise AssertionError("Test failed!")
    else:
        print("SUCCESS: Test passed!")
        print(f"  Inputs: dividend = {int(dut.dividend.value)}, divisor = {int(dut.divisor.value)}")
        print(f"  Output: quotient = {int(dut.quotient.value)}, remainder = {int(dut.remainder.value)}")

        
@cocotb.test()
async def array_divider_tb(dut):
    """Testbench for array_divider"""
    # Start the clock
    cocotb.start_soon(Clock(dut.clk, 5, units='ns').start())

    # Apply the reset sequence
    await reset_sequence(dut)


    # Apply inputs and check outputs in a loop
    for _ in range(10):
        await driver(dut)  # Apply new inputs
        await monitor(dut)
