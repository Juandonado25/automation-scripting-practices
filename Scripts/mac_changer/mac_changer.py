import subprocess
import argparse
import re

class Macchanger:
	def validate_mac(self,mac):
		"""Validates MAC address format XX:XX:XX:XX:XX:XX"""
		pattern = r"^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"
		return re.match(pattern, mac) is not None
	
    def validate_interface(self,interface):
        result = subprocess.run(["ip","link","show",interface], capture_output=True)
		return result.returncode == 0

    def get_arguments(self):
		parser = argparse.ArgumentParser()
		parser.add_argument("-i","--interface",dest="interface",help="interface to change its MAC address")
		parser.add_argument("-m","--mac",dest="new_mac",help="New MAC address")
		options = parser.parse_args()
		if not options.interface:
			parser.error("[-] Please specify an interface, use --help for more info.")
		elif not self.validate_interface(options.interface)
		    parser.error(f"[-] Interface '{options.interface}' not found or invalid.")
		elif not options.new_mac:
			parser.error("[-] Please specify a new MAC address. use --help for more info.")
		elif not self.validate_mac(options.new_mac):
			parser.error("[-] Invalid MAC address format. Use XX:XX:XX:XX:XX:XX (e.g. 00:66:22:77:11:88).")
		return options

	def change_mac(self,interface,new_mac):
		print(f"[+] Changing MAC address of interface '{interface}' to '{new_mac}'...")
		subprocess.call(["sudo","ifconfig",interface,"down"])
		subprocess.call(["sudo","ifconfig",interface,"hw","ether",new_mac])
		subprocess.call(["sudo","ifconfig",interface,"up"])
		print(f"[+] MAC address changed successfully.")
	
def main():
	mac_changer = Macchanger()
	options = mac_changer.get_arguments()
	mac_changer.change_mac(options.interface,options.new_mac)
	
if __name__ == "__main__":
    main()