# Floating Point Adder Multiplier

## Contents of Readme

1. About
2. Modules
3. Interface Description
4. Performance and Resource Utilization
5. Simulation
6. Test
7. Status Information
8. Issues

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/fpam)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/FPAM)

---

## About

**Work in Progress!**

Fully combinational adder and multiplier modules for IEEE 754 single-precision (binary32) and double-precision (binary64) floating point format.

## Modules

Two computation modules and a simple wrapper that contains both adder and multiplier.

## Interface Description

### Ports

Ports of the all modules/IPs named in same manner.

|   Port   | Type | Width | Occurrence | Description | Notes |
| :------: | :----: | :----: | :----: | :-----:  | ---- |
| `num0` | I | `BIT_SIZE` | Mandatory | Operand | |
| `num1` | I | `BIT_SIZE` | Mandatory | Operand | |
| `res` | O | `BIT_SIZE` | Mandatory | Result | |
| `overflow` | O | 1 | Optional | Result is infinite / Overflowed | |
| `zero` | O | 1 | Optional | Result is zero | |
| `NaN` | O | 1 | Optional | At least one of the inputs are not a number | |
| `precisionLost` | O | 1 | Optional | Precision Lost in Result | |
| `flagRaised` | O | 1 | Optional | One of the Implemented Flags are raised | |
| `select` | I | 1 | Optional | Select Operation | Only in wrapper |

I: Input  O: Output

### Parameters

Following parameters can be used to modify the size of operation and the output flags.

|Parameter|Possible Values|Description|
| :----: | :-----:  | ---- |
| `BIT_SIZE` | _32_, _64_ | Operation Size |
| `ENABLE_FLAGS_MASTER` | bool | Master enable for flags |
| `ENABLE_FLAGS_COMMON` | bool | Enable `flagRaised` |
| `ENABLE_FLAGS_OF` | bool | Enable `overflow` |
| `ENABLE_FLAGS_ZERO` | bool | Enable `zero` |
| `ENABLE_FLAGS_NaN` | bool | Enable `NaN` |
| `ENABLE_FLAGS_PLost` | bool | Enable `precisionLost` |

For custom exponent formats, one can enable "value override" mode with `FORMAT_OVERRIDE` and enter corresponding widths to `EXPONENT_SIZE_OR` and `FRACTION_SIZE_OR`. Sign bit is always 1 bit. Custom formats are not tested.

## Performance and Resource Utilization

All values in this section are for Xilinx Artix-7 (_XC7A100TCSG324-1_) FPGA.

### Single-Precision Adder

- Utilization after synthesis: 473 LUT as Logic
- Maximum clock frequency (for input output registers): 65 MHz

### Double-Precision Adder

- Utilization after synthesis: 985 LUT as Logic
- Maximum clock frequency (for input output registers): 50 MHz

## Simulation

Test benches will both generate a waveform and display overview of the test cases. Overview messages show operands, result, manually calculated expected result, and flag information.

[convertFloat.py](scripts/convertFloat.py) can be used to help with verification. It should convert values between formats. However this script is not thoroughly tested.

## Test

Hardware tests of all modules is done by a [VIO](https://www.xilinx.com/products/intellectual-property/vio.html) and placing a [register](Util/register.v) between [VIO](https://www.xilinx.com/products/intellectual-property/vio.html) and module ports.

## Status Information

**Last Simulation:**

- Single-Precision Adder: 1 December 2022, with [Icarus Verilog](http://iverilog.icarus.com/).

## Issues

Nothing so far.

For newly found bugs; [contact me](https://suoglu.github.io/contact.html), open an issue at [gitlab (preferred)](https://gitlab.com/suoglu/fpam/-/issues/new) or [github](https://github.com/suoglu/FPAM/issues/new).
