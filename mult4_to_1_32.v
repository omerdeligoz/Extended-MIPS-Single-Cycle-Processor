module mult4_to_1_32 (out, i0, i1, i2, i3, s1, s2, s3);
  output [31:0] out;  		// Output declared as wire
  input [31:0] i0, i1, i2, i3;  // Two 32-bit inputs
  input s3, s2, s1;  	   // s1= (balrv & status[0]) | jsp
			   // s2= baln & status[1]
			   // s3= jmxor

  assign out = (s3) ? i3 : 	// out = ReadData (dpack)	
               (s2) ? i2 : 	// out = JumpTarget	
               (s1) ? i1 : 	// out = ReadData1 (dataa)	
		      i0 ;	// out = out4	
endmodule
