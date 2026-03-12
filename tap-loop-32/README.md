The Xilinx Zynq UltraScale+ devices contain a two clusters of ARM cores and quite a lot of extrac omplexity compared to the 7-series Zynq family. The JTAG chain is also more complex, which is what this project focuses on.

- [x] Open JTAG chain
- [x] Set JTAG-TAP in USER4 mode
- [ ] Wire USER4 mode state to an user LED

# Notes

User LEDs in the K26 XDC:

```tcl
set_property PACKAGE_PIN F8 [get_ports "som240_1_d13"]; # Bank 66 VCCO - som240_1_d1 - IO_L17P_T2U_N8_AD10P_66
set_property PACKAGE_PIN E8 [get_ports "som240_1_d14"]; # Bank 66 VCCO - som240_1_d1 - IO_L17N_T2U_N9_AD10N_66
```
