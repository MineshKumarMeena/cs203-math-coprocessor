CS203 Math Coprocessor

Overview

This project implements a mathematical coprocessor using Verilog HDL and fixed-point Q16.16 arithmetic.

Supported Operations

Exponential function: e^x

Natural logarithm: ln(x)

Sine function: sin(x)

Design

The design accepts an operation code and input value, then returns the calculated result along with done and error status signals.

Verification

A Verilog testbench checks the hardware outputs against expected mathematical values, measures total numerical error, and tests invalid inputs.
