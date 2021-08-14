from pathlib import Path
from os.path import join
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent

# Sources path for DUT
SRC_PATH = ROOT / "source" 
MATH_LIBRARY_PATH = "math_library"
SYSTEM_CONTROL_PATH = "system_control"

VU = VUnit.from_argv()

lib = VU.add_library("lib")
lib.add_source_files(SRC_PATH / "*.vhd") 

lib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "first_order_filter" / "*.vhd") 
lib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "multiplier" / "*.vhd") 
lib.add_source_files(SRC_PATH / MATH_LIBRARY_PATH / "multiplier" /  "simulation" /"*.vhd") 

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "adc_interface" / "spi_sar_adc" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "adc_interface" / "spi_sar_adc" / "simulation" /"*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "gate_drive_power" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "simulation" /"*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "uart_rx" /"*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "uart" / "uart_transreceiver" / "uart_tx" /"*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_receiver" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_receiver" / "ethernet_frame_receiver_simulation"/ "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_receiver" / "ethernet_rx_ddio" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_receiver" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_transmitter" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_transmitter" / "ethernet_frame_transmitter_simulation" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet" / "ethernet_frame_transmitter" / "ethernet_tx_ddio" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet_common" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "ethernet_common" / "dual_port_ethernet_ram" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "internet_layer" / "internet_protocol" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "link_layer" / "ethernet_protocol" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "ethernet_communication" / "network_protocol_stack" / "transport_layer" / "user_datagram_protocol" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "*.vhd")
lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "power_supply_control" / "gate_drive_power" / "*.vhd")

lib.add_source_files(SRC_PATH / SYSTEM_CONTROL_PATH / "system_components" / "*.vhd")

VU.main()
