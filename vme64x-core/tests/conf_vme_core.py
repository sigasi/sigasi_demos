import pyvmelib
import sys

class CVMeCrPos:
    def __init__(self, add, nbytes, nfunc, ptype, name):
        self.name = name;
        self.nbytes = nbytes;
        self.add = add;
        self.value = [0] * nbytes;
        self.readdone = 0;
        self.writedone = 0;
        self.debug = 1;
        self.ptype = ptype;
        self.nfunc = nfunc;

    def read(self, map):
        for i in range(0,self.nbytes*self.nfunc):
            vtemp= map.read(offset=self.add-3+i*4, width=32)[0];
            self.value[i] =vtemp >> 24;
            self.readdone=1+self.readdone;
        print "I am going to check debug mode"
        if self.debug == 1:
            print self.name;
            print self.readdone;
            print [ hex(x) for x in self.value ]
            print "I should have printed name and value"

    def write(self, map, data): 
        for i in range(data):
            map.write(offset=self.add-3+i*4, width=32, values=data[i])
        self.writedone=1+self.writedone;

class CVmeCrList:
    def __init__(self,ga):
   #     par = self.parityOf(ga);
        self.gad = (ga <<19);
        self.size = 0x10000;
        self.data_width = 32;
        self.am = 0x2f;
	print '%x' % self.gad
        self.map = pyvmelib.Mapping(am=0x2f, base_address=self.gad, data_width=self.data_width, size=self.size);
	if self.map.vaddr is None:
		print "mapping failed!"
		sys.exit()
        self.cr = {
                   #CR Start
                   "CHKSUM": CVMeCrPos(0x03,1,1,"CR","CHKSUM"), 
                   "CRDW":  CVMeCrPos(0x13,3,1,"CR","CRDW"), 
                   "ACSRDW": CVMeCrPos(0x17,1,1,"CR","ACSRDW"), 
                   "SPACEID": CVMeCrPos(0x1B,1,1,"CR","SPACEID"),
                   "CASCII": CVMeCrPos(0x1F,1,1,"CR","CASCII"),
                   "RASCII": CVMeCrPos(0x23,1,1,"CR","RASCII"),
                   "MID": CVMeCrPos(0x27,3,1,"CR","MID"),
                   "BID": CVMeCrPos(0x33,4,1,"CR","BID"),
                   "RID": CVMeCrPos(0x43,4,1,"CR","RID"),
                   "STRP": CVMeCrPos(0x53,3,1,"CR","STRP"),
                   "PID": CVMeCrPos(0x7F,8,1,"CR","PID"),
                   "FDAW": CVMeCrPos(0x103,1,8,"CR","FDAW"),
                   "AMCAP": CVMeCrPos(0x123,8,8,"CR","AMCAP"),   
                   "XAMCAP": CVMeCrPos(0x223,32,8,"CR","XAMCAP"),
                   "ADEM": CVMeCrPos(0x623,4,8,"CR","ADEM"),
                   "MDAWPR": CVMeCrPos(0x6AF,1,1,"CR","MDAWPR"),
                   "MAMCAP": CVMeCrPos(0x6B3,8,1,"CR","MAMCAP"),
                   "MXAMCAP": CVMeCrPos(0x6D3,32,1,"CR","MXAMCAP"),
                   #CSR Start
                   "CSCSRBAR":  CVMeCrPos(0x7ffff,1,1,"CSR","CSCSRBAR"),
                   "BSR": CVMeCrPos(0x7FFFB,1,1,"CSR","BSR"),
                   "BCR": CVMeCrPos(0x7FFF7,1,1,"CSR","BCR"),
                   "CRAM_OWNER": CVMeCrPos(0x7FFF3,1,1,"CSR","CRAM_OWNER"),
                   "UDBS": CVMeCrPos(0x7FFEF,1,1,"CSR","UDBS"),
                   "UDBC": CVMeCrPos(0x7FEB,1,1,"CSR","UDBC"),
                   "ADER": CVMeCrPos(0x,4,8,"CSR","ADER"),                 
                   }
        
            
        
        

#    def parityOf(int_type):
#        parity = 0;
#        while (int_type):
#            parity = ~parity
#            int_type = int_type & (int_type - 1)
#            return(parity);
        
    def readCR(self):
        for s in self.cr:
	    print s
            self.cr[s].read(self.map);





##for i in range(16):
print "I am going to create modcr= CVmeCrList(6)"
modcr= CVmeCrList(6)
print "I am going to read modcr.readCR"
modcr.readCR()

##map = pyvmelib.Mapping(am=0x2f, base_address=0x300000, data_width=32, size=0x10000);


#for s in  
#value = modcr.map.read(offset=0x4, num=1, width=32)[0]
#print hex(value)

#map.write(offset=0x3, width=8, values=0xa5)
#map.write(offset=0x3, width=8, values=[0xa5, 0xff])
