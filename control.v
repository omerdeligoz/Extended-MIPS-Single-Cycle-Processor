module control(in,instruc,status,dataa,balrv,jmxor,baln,jsp,bgezal,ori,
		memtoreg1,regdest1,regdest0,alusrc,memtoreg0,regwrite,memread,memwrite,branch,aluop1,aluop2);
input [5:0] in;
input [31:0] dataa,instruc;
input [2:0] status;
output balrv,jmxor,baln,jsp,bgezal,ori,
	memtoreg1,regdest1,regdest0,alusrc,memtoreg0,regwrite,memread,memwrite,branch,aluop1,aluop2;
wire [4:0] inst20_16 = instruc[20:16];
wire [4:0] inst15_11 = instruc[15:11];
wire [5:0] inst5_0 = instruc[5:0];

wire rformat,lw,sw,beq;
wire [5:0] opcode = {in[5],in[4],in[3],in[2],in[1],in[0]};
assign rformat= (in == 6'b0);

assign jmxor = rformat & (~|inst15_11) & (inst5_0 == 6'd34);  	// R-type and funct=34 and rd=0(to seperate from sub)
assign balrv = rformat & (inst5_0 == 6'd22);			// R-type and funct=22 
assign baln = opcode == 6'd27;
assign jsp = opcode == 6'd18; 
assign bgezal = (opcode == 6'd35) & (~|inst20_16);  		// Opcode=35 and rt=0(to seperate from lw)
assign ori = opcode == 6'd13; 


assign lw=((in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0])) & (|inst20_16);  //opcode=35 and rt != 0
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign regdest0=rformat|baln;
assign regdest1 = baln|jmxor|bgezal;
assign alusrc=lw|sw;
assign memtoreg0=lw;
assign regwrite= (rformat & ~balrv) | lw | ori | (bgezal & ~dataa[31]) | (baln & status[1]) | (balrv & status[0]);
assign memread=lw|jsp|jmxor;
assign memwrite=sw;
assign branch=beq;
assign aluop1 = ori ? 1'b1 : rformat;	//if (ori control==1) 	aluop = 11 
assign aluop2 = ori ? 1'b1 : beq;	//else 			aluop =rformat,beq
assign memtoreg1 = baln|balrv|bgezal|jmxor;

endmodule
