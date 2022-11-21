# Floating Point Adder Multiplier

## Contents of Readme

1. About
2. Modules
3. Interface Description
<!-- 4. Performance and Resource Utilization
5. Simulation
6. Test
7. Status Information
8. Issues -->

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/fpam)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/FPAM)

---

## About

Combinational adder and multiplier modules for IEEE 754 single-precision and double-precision floating point format.

## Modules

Two computation modules and a simple wrapper that contains both adder and multiplier.

## Interface Description

### Ports

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

|Parameter|Possible Values|Description|
| :----: | :-----:  | ---- |
| `BIT_SIZE` | _32_, _64_ | Operation Size |
| `ENABLE_FLAGS_MASTER` | bool | Master enable for flags |
| `ENABLE_FLAGS_COMMON` | bool | Enable `flagRaised` |
| `ENABLE_FLAGS_OF` | bool | Enable `overflow` |
| `ENABLE_FLAGS_ZERO` | bool | Enable `zero` |
| `ENABLE_FLAGS_NaN` | bool | Enable `NaN` |
| `ENABLE_FLAGS_PLost` | bool | Enable `precisionLost` |
| `Common Input` | bool | In wrapper, both adder and multiplier uses same inputs |
| `Common Output` | bool | In wrapper, both adder and multiplier uses same outputs, enables `select`  |

<!-- 
## Simulation

INFO ABOUT SIMULATION

## Test

INFO ABOUT TEST CODE 

## Status Information

**Last Simulation:** -

**Last Test:** - -->
