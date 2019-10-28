import pyvmelib

map = pyvmelib.Mapping(am=0x2f, base_address=0xXXXXXX, data_width=16, size=0x10000)

value = map.read(offset=0x3, width=8)[0]
print hex(value)

map.write(offset=0x3, width=8, values=0xa5)
map.write(offset=0x3, width=8, values=[0xa5, 0xff])
