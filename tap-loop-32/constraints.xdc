# clock constraints

    create_clock -name TCK -period 20 [get_pins */TCK_INTERNAL]

# user LEDs

    set_property PACKAGE_PIN F8 [get_ports "som240_1_d13"]; # Bank 66 VCCO - som240_1_d1 - IO_L17P_T2U_N8_AD10P_66
    set_property PACKAGE_PIN E8 [get_ports "som240_1_d14"]; # Bank 66 VCCO - som240_1_d1 - IO_L17N_T2U_N9_AD10N_66
    set_property IOSTANDARD LVCMOS18 [get_ports som240_1_d*];
