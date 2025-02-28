module processor;
reg [31:0] pc; 		//32-bit prograom counter
reg clk; 		//clock
reg [7:0] datmem[0:31]; //32-size data memory (8 bit(1 byte) for each location)
reg [7:0] mem[0:255];	//256-size instruction memory (8 bit(1 byte) for each location)
wire [2:0] status;
wire [31:0] 
dataa,		//Read data 1 output of Register File
datab,		//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out2a,
out3a,
out4a,
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,		//Output of sign-extend unit
zextout, 	//Output of zero-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,		//Output of shift left 2 unit
jumpAddress;



wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
inst5_0,	//15-11 bits of instruction
out1,		//Write data input of Register File
out5;
wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;			//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,		//Zero output of ALU
pcsrc,			//Output of AND gate with Branch and ZeroOut inputs

//Control signals
regdest1,regdest0,alusrc,memtoreg0,regwrite,memread,memwrite,branch,aluop1,aluop0,
balrv,baln,jmxor,jsp,bgezal,ori,
memtoreg1;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[8:0]],mem[pc[8:0]+1],mem[pc[8:0]+2],mem[pc[8:0]+3]};	// Changed to increase instruction memory
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst5_0 = instruc[5:0];
 assign inst15_0=instruc[15:0];
 assign jumpAddress = {adder1out[31:28], instruc[25:0], 2'b00}; // JumpAddress = [Pc+4]+[address*4]

// registers

assign dataa=registerfile[out5];	//Read register 1 (Coming from newly added mult5)
assign datab=registerfile[inst20_16];	//Read register 2
always @(posedge clk)
 registerfile[out1]= regwrite ? out3a:registerfile[out1];	//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

//multiplexers
//mux with RegDst control
//mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);        CHANGED TO 4 INPUT MUX!!
mult4_to_1_5  mult1(out1, instruc[20:16], instruc[15:11], 5'd25, 5'd31, regdest1, regdest0);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);
mult2_to_1_32 mult2a(out2a, out2,zextout,ori);  		// ADDED!!


//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg0);
mult2_to_1_32 mult3a(out3a, out3,adder1out,memtoreg1);  	// ADDED!!

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);
mult4_to_1_32 mult4a(out4a, out4, dataa, jumpAddress, dpack, 	// ADDED!!
			((balrv & status[0]) | jsp),		// 
			(baln & status[1]),
			(jmxor));


// new mux for ReadReg1
mult2_to_1_5 mult5(out5,inst25_21,5'd29,jsp);			// ADDED!!




// load pc
always @(negedge clk)
pc=out4a;

// alu, adder and control logic connections

//ALU unit
alu32 alu1(clk,status,sum,dataa,out2a,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],instruc,status,dataa,
	balrv,jmxor,baln,jsp,bgezal,ori,
	memtoreg1,regdest1,regdest0,alusrc,memtoreg0,regwrite,memread,memwrite,branch,aluop1,aluop0);

//Sign extend unit
signext sext(instruc[15:0],extad);

//Zero extend unit
zeroext zext(instruc[15:0],zextout);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,jmxor ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate
assign pcsrc= (branch && zout) | (bgezal & ~dataa[31]); 

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<=127; i=i+4)
	$display("Instruction Memory[%0d]= %h %h %h %h  ",i,mem[i],mem[i+1],mem[i+2],mem[i+3]);

	for(i=0; i<=31; i=i+1)
	$display("Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#1040 $finish;
end

initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end

initial 
begin
  $monitor($time,"    PC %h",pc,"    SUM %h",sum,"    INST %h",instruc[31:0],"    NextPc %h",out4a);
end
endmodule

