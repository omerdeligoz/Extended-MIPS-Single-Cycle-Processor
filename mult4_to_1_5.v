module mult4_to_1_5 (out, i0, i1, i2, i3, s1, s0);
  output [4:0] out;  // Output declared as wire
  input [4:0] i0, i1,i2,i3;      // Foru 5-bit inputs
  input s1, s0;  	   // s1= Regdest1
			   // s0= RegDest0

  assign out = ({s1, s0} == 2'b00) ? i0 : 		//WriteReg = instruction[20:16]
               ({s1, s0} == 2'b01) ? i1 : 		//WriteReg = instruction[15:11]
               ({s1, s0} == 2'b10) ? i2 : 		//WriteReg = $25		(bgezal)
               			     i3 ; 		//WriteReg = $31 (2'b11 case)  	(baln and jmxor)
endmodule

