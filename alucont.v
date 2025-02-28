module alucont(aluop1,aluop0,f3,f2,f1,f0,jmxor,gout);//Figure 4.12 
input aluop1,aluop0,f3,f2,f1,f0,jmxor;
output [2:0] gout;
reg [2:0] gout;
wire [3:0] func_code = {f3, f2, f1, f0};
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
	if(~(aluop1|aluop0))  	gout=3'b010;  		// 00 case   	lw and sw	add
	if(~aluop1&aluop0)	gout=3'b110;		// 01 case	beq		sub
	if(aluop1&aluop0)	gout=3'b001;		// 11 case	ori             or
	if(aluop1&~aluop0)				// 10 case	R-type
	begin			
		case (func_code)
        	4'b0000: gout = 3'b010; 			// add   
		4'b0010: begin 	
				if (jmxor) gout = 3'b011; 	// xor
				else gout = 3'b110; 		// sub;
			 end
        	4'b0100: gout = 3'b000; 			// and
        	4'b0101: gout = 3'b001; 			// or
		4'b1010: gout = 3'b111;				// slt
		endcase
	end
end
endmodule
