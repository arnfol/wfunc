# Test plan for window_func module

## Test cases
### Parameters:
* **FFT_SIZE**  = 128, 512, 2048, 4096, 8192 
* **BUS_NUM**   = 2, 4, 8    
* **APB_A_REV** = 0, 1    

### Interfaces:
* AXIS:
	* VALID & READY:
		* IN: always, OUT: always
		* IN: random, OUT: always
		* IN: always, OUT: random
		* IN: random, OUT: random
* APB REGISTERS:
	* RESET VALUES
	* REGISTER TYPES

## FSM test:
* Check state switches:
	* _CHANGE_STATE_
	* _SOFT_RESET_
	* Check move to _BUSY_ state.
* Check impossibility to change window registers when not in _IDLE_.
* Check whether in one-packet mode FSM goes to _IDLE_ after receipt.

## Priority
| Name           | Priority |
| -------------- | -------- |
| **Parameters** |          |
| FFT_SIZE: ALL  | DONE     |
| BUS_NUM: ALL   | DONE     |
| APB_A_REV: 0   | DONE     |
| APB_A_REV: 1   | LOW      |
| **Interfaces** |          |
| AXIS           | DONE     |
| APB            | *HIGH*   |
| **FSM**        | *HIGH*   |

