module alu32(clk,status,sum,a,b,zout,gin);//ALU operation according to the ALU control line values
output [31:0] sum;
output reg [2:0] status;
input [31:0] a,b; 
input [2:0] gin;//ALU control line
input clk;
reg [31:0] sum;
reg [31:0] less;
output zout;
reg zout;
always @(a or b or gin)
begin
	case(gin)
	3'b010: sum=a+b; 		//ALU control line=010, ADD
	3'b110: sum=a+1+(~b);		//ALU control line=110, SUB
	3'b111: begin less=a+1+(~b);	//ALU control line=111, set on less than
			if (less[31]) sum=1;	
			else sum=0;
		  end
	3'b000: sum=a & b;		//ALU control line=000, AND
	3'b001: sum=a|b;		//ALU control line=001, OR
	3'b011: sum=a^b;		//ALU control line=011, XOR  (ADDED!)
	default: sum=32'bx;		
	endcase
zout=~(|sum);
end


always @(negedge clk) begin
        status[2] <= (sum == 32'b0); 	// Z (Zero)
        status[1] <= (sum[31]); 	// N (Negative)
        // Overflow for addition and subtraction
	if(gin == 3'b010) 
        	status[0] <= (~a[31] && ~b[31] && sum[31]) | (a[31] && b[31] && ~sum[31]); // Add overflow
	else if(gin == 3'b110) 
                status[0] <= (~a[31] && b[31] && sum[31]) | (a[31] && ~b[31] && ~sum[31]); // Subtract overflow
end
endmodule
